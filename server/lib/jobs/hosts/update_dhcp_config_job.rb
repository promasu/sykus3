require 'common'

module Sykus; module Hosts

  # Updates the DHCP config file with static IP assignments for all hosts.
  class UpdateDHCPConfigJob
    extend Resque::Plugins::Queue::Lock
    extend Resque::Plugins::Workers::Lock
    @queue = :fast

    # Config file path.
    CONFIG_FILE = '/etc/dhcp/sykus.dynamic.conf'

    # Runs the job.
    def self.perform
      File.open CONFIG_FILE, 'w+' do |f|
        Host.all.each do |host|
          hostname = host.host_group.name + '-' + host.name 
          pxefile = 'conf.d/' + host.mac.gsub(':', '')

          f.write "host #{hostname} { "
            f.write "hardware ethernet #{host.mac}; "
            f.write "fixed-address #{host.ip}; "
            f.write "option host-name \"#{hostname}\"; "
            f.write "option pxelinux.configfile \"#{pxefile}\"; "
            f.write "}\n"
        end
      end

      system 'sudo stop isc-dhcp-server; sudo start isc-dhcp-server'
    end
  end

end; end

