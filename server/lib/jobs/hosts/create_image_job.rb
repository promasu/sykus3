require 'common'

require 'jobs/hosts/update_pxe_link_job'

module Sykus; module Hosts

  # Creates a new client image.
  class CreateImageJob
    extend Resque::Plugins::Lock
    @queue = :image

    # Work directory.
    WORK_DIR = '/var/lib/sykus3/clibuild'

    # Base config directory.
    CONF_DIR = '/usr/lib/sykus3/server/cli/conf'

    # Package config directory.
    PACKAGE_DIR = '/usr/lib/sykus3/server/cli/packages'

    # Client Daemon directory.
    DAEMON_DIR = '/usr/lib/sykus3/server/cli/daemon'

    # Virtual machine config dir.
    VMENV_DIR = '/usr/lib/sykus3/server/cli/vmenv'

    # Client base image path.
    BASE_VOLUME = '/usr/lib/sykus3/dist/sykuscli.qed'

    # Image destination path.
    DEST_DIR = '/var/lib/sykus3/image'

    # Runs the job.
    def self.perform(now)
      return wait_for_sunset unless now

      # remove scheduled job if present
      Resque.dequeue CreateImageJob, false

      # 3 hours timeout
      Timeout::timeout(3 * 3600) do
        LOG.info 'Cleanup and environment setup'
        `sudo bash /usr/lib/sykus3/server/cli/cleanup.sh`
        FileUtils.rm_rf WORK_DIR
        FileUtils.mkdir WORK_DIR
        FileUtils.cp BASE_VOLUME, WORK_DIR + '/sykuscli.qed'

        LOG.info 'Creating SSH keypair.'
        create_ssh_key

        LOG.info 'Preparing chef data.'
        prepare_chef
        LOG.info 'Creating VM environment.'
        vmenv
        LOG.info 'Running chef.'
        run_chef

        LOG.info 'Extracting image.'
        `sudo bash /usr/lib/sykus3/server/cli/export.sh`

        LOG.info 'Moving image files.'
        FileUtils.mv WORK_DIR + '/release.img', DEST_DIR
        FileUtils.mv WORK_DIR + '/release.img.size', DEST_DIR

        LOG.info 'Setting reinstall flags.'
        reinstall_hosts

        LOG.info 'Imaging Done.'
      end
    end

    private

    # Returns variable data for client data bag.
    def self.data_bag
      conf = {}

      %w{
        wlan_ssid wlan_key radius_client_password 
        smartboard_serial
      }.each do |name|
        conf[name.to_sym] = Config::ConfigValue.get name
      end

      conf.merge({
        ssh_pubkey: File.read('/var/lib/sykus3/sshkey_cli.pub'),
        radius_ca: File.read('/etc/freeradius/certs/ca.pem'),
        server_domain: Socket.gethostname,
      })
    end

    # Image is scheduled to be created when nobody is using
    # the system, i.e. at night.
    def self.wait_for_sunset
      sleep 20 until (Time.now.hour > 21 || Time.now.hour < 4)
      Resque.enqueue CreateImageJob, true
    end

    # Create a new SSH key pair.
    def self.create_ssh_key
      Dir.chdir '/var/lib/sykus3/' do
        raise unless system 'rm -f sshkey_cli*'
        raise unless system 'ssh-keygen -t rsa -f sshkey_cli -P ""'
      end
    end

    # Creates list of cookbooks and apt packages 
    # that are to be included in the image.
    def self.prepare_chef
      apt_list = Set.new
      cookbook_list = Set.new

      Package.all(selected: true).each do |package|
        data = YAML.load_file "#{PACKAGE_DIR}/#{package.id_name}.yaml"
        apt_list += data['apt'].to_a
        if Dir.exists? "#{PACKAGE_DIR}/#{package.id_name}"
          cookbook_list += [ package.id_name ]
        end
      end

      Package.all.each do |package|
        package.installed = package.selected
        package.save
      end

      File.open(WORK_DIR + '/apt.json', 'w+') do |f|
        f.write apt_list.to_a.to_json
      end
      File.open(WORK_DIR + '/cookbooks.json', 'w+') do |f|
        f.write cookbook_list.to_a.to_json
      end
    end

    # Creates the VM environment with machine and network setup.
    def self.vmenv
      Dir.chdir VMENV_DIR do 
        `virsh net-destroy sykuscli`
        `virsh net-undefine sykuscli`
        `virsh net-define network.sykuscli.xml`
        `virsh net-autostart sykuscli`
        `virsh net-start sykuscli`

        `virsh destroy sykuscli`
        `virsh undefine sykuscli`
        `virsh define domain.sykuscli.xml`
        `virsh start sykuscli`
      end
    end

    # Run chef and install software packages.
    def self.run_chef
      opts = {
        password: 'sykusroot',
        timeout: 2,
        global_known_hosts_file: [],
        user_known_hosts_file: [],
      }

      LOG.info 'Waiting for SSH...'
      begin
        Net::SSH.start('10.41.1.1', 'root', opts) do |ssh|
          LOG.info 'SSH connected.'

          ssh.exec! 'mkdir -p /tmp/conf/packages'
          ssh.sftp.upload! CONF_DIR, '/tmp/conf'
          ssh.sftp.upload! WORK_DIR + '/apt.json', '/tmp/conf/apt.json'
          ssh.sftp.upload! WORK_DIR + '/cookbooks.json', 
            '/tmp/conf/cookbooks.json'
          ssh.sftp.upload! PACKAGE_DIR, '/tmp/conf/packages'

          ssh.exec! 'mkdir -p /usr/lib/sykus3/daemon'
          ssh.sftp.upload! DAEMON_DIR, '/usr/lib/sykus3/daemon'

          ssh.exec! 'mkdir -p /tmp/data_bag/client'
          f = Tempfile.new('client.json')
          f.write({ id: 'client' }.merge(data_bag).to_json)
          f.close
          ssh.sftp.upload! f.path, '/tmp/data_bag/client/client.json'
          f.unlink

          LOG.info 'Running chef (main)...'
          output = ''
          ssh.exec!('cd /tmp/conf; chef-solo -c cli.rb -j main.json') \
            { |ch, type, data| output << data; print data }

          unless output.include? 'Chef Run complete'
            LOG.error 'Chef failed'
            raise
          end

          LOG.info 'Running chef (cleanup)...'
          output = ''
          ssh.exec!('cd /tmp/conf; chef-solo -c cli.rb -j cleanup.json') \
            { |ch, type, data| output << data; print data }

          unless output.include? 'Chef Run complete'
            LOG.error 'Chef failed'
            raise
          end

          ssh.exec! 'rm -rf /tmp/conf /tmp/data_bag'
          ssh.exec! 'poweroff'
        end
      rescue Timeout::Error
        sleep 3
        retry
      end

      LOG.info 'Waiting for poweroff.'
      sleep 5 until `virsh domstate sykuscli`.strip == 'shut off'
      LOG.info 'Successful.'
    end

    # Set reinstall flag on all hosts.
    def self.reinstall_hosts
      Host.all(ready: true).each do |host|
        host.ready = false
        host.save
        entity_evt = EntityEvent.new(EntitySet.new(Host), host.id, false)
        EntityEventStore.save entity_evt
        Resque.enqueue UpdatePXELinkJob, host.id
      end
    end

  end

end; end

