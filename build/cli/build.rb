module CliBuild
  extend self

  ISO_URL = 'http://releases.ubuntu.com/13.04/ubuntu-13.04-server-i386.iso'

  def run
    vmenv
    download_iso
    preseed_server
    build
    configure
  end

  private
  def cmd(*args)
    print 'Running: '
    puts *args
    system *args
  end

  def preseed_server
    Thread.new do
      Net::HTTP::Server.run port: 7000 do
        [ 200, {}, [ File.read('preseed.cfg') ] ]
      end
    end
  end

  def download_iso
    Dir.mkdir '../../cache' unless Dir.exists? '../../cache'
    return if File.exists? '../../cache/cli_os.iso'
    `wget -O ../../cache/cli_os.iso #{ISO_URL}`
  end

  def vmenv
    Dir.mkdir 'volumes' unless Dir.exists? 'volumes'

    cmd 'virsh net-destroy sykus'
    cmd 'virsh net-undefine sykus'
    cmd 'virsh net-define network.sykus.xml'
    cmd 'virsh net-autostart sykus'
    cmd 'virsh net-start sykus'

    cmd "virsh destroy sykuscli"
    cmd "virsh undefine sykuscli"
    File.open('tmp.xml', 'w+') do |f|
      data = File.read "domain.sykuscli.xml"
      data.gsub! '{{BASEDIR}}', Dir.pwd
      data.gsub! '{{ISOFILE}}', 
        File.expand_path(Dir.pwd + '/../../cache/cli_os.iso')
      f.write data
    end
    cmd "virsh define tmp.xml"
    FileUtils.rm_f 'tmp.xml'
  end

  def build
    Dir.chdir 'volumes' do
      FileUtils.rm_f 'sykuscli.qed' if File.exists? 'sykuscli.qed'
      cmd 'qemu-img create -f qed sykuscli.qed 7G'
      cmd 'chmod 777 *'
    end

    cmd 'virsh start sykuscli'
    sleep 5
    Net::VNC.open 'localhost:0', shared: true do |vnc|
      vnc.key_press :escape
      vnc.key_press :escape
      vnc.key_press :return

      # wait for boot prompt
      sleep 5

      # send individual chars to prevent pressing keys too fast
      # vnc#type uses a 0.1 delay by default
      [
        '/install/vmlinuz noapic',
        'preseed/url=http://10.31.0.1:7000/preseed.cfg',
        'debian-installer=de_DE auto locale=de_DE',
        'keyboard-configuration/layoutcode=de hostname=sykuscli',
        'fb=false debconf/frontend=noninteractive',
        'console-setup/ask_detect=false',
        'localechooser/translation/warn-light=true',
        'localechooser/translation/warn-severe=true',
        'initrd=/install/initrd.gz -- '
      ].join(' ').split(//).each do |char| 
        # we send keycodes and we use US keyboard layout
        # some keys require pressing shift.
        # this is a bug that should be fixed in Net::VNC
        if 'ABCDEFGHIJKLMNOPQRSTUVWXYZ~!@#$%^&*()_+{}|:"<>?'.include? char
          vnc.key_down :shift
          vnc.type char
          vnc.key_up :shift
        else
          vnc.type char
        end
      end

      vnc.key_press :return
    end
  end

  def configure
    opts = {
      password: 'sykusroot',
      timeout: 2,
      global_known_hosts_file: [],
      user_known_hosts_file: [],
    }
    begin
      Net::SSH.start('10.31.0.2', 'root', opts) do |ssh|
        tmp = '/tmp/postinstall.sh'
        ssh.sftp.upload! 'postinstall.sh', tmp
        ssh.exec!("chmod +x #{tmp}") { |ch, type, data| print data }
        puts ssh.exec! tmp
      end
    rescue Timeout::Error, Errno::ECONNREFUSED
      print '.'
      sleep 3
      retry
    end

    until `virsh domstate sykuscli`.strip == 'shut off'
      sleep 5
      print '.'
    end
    puts 'Done.'
  end
end

