require 'common'

require 'jobs/hosts/update_pxe_link_job'
require 'jobs/hosts/update_dhcp_config_job'

module Sykus; module Hosts

  # Creates a new Host.
  class CreateHost < ServiceBase
    # @param [Hash] args Hash of new host attributes. 
    # @return [Hash/Integer] Host ID.
    def action(args)
      enforce_permission! :hosts_create

      host = Host.new select_args(args, [ :name, :mac ])
      host.mac = host.mac.downcase
      host.ip = get_ip

      if args[:host_group].is_a? String
        host_group = HostGroup.first(name: args[:host_group])
      elsif args[:host_group].is_a? Integer
        host_group = HostGroup.get(args[:host_group])
      end
      raise Exceptions::NotFound, 'HostGroup not found' if host_group.nil?
      host.host_group = host_group

      validate_entity! host

      host.save
      entity_evt = EntityEvent.new(EntitySet.new(Host), host.id, false)
      EntityEventStore.save entity_evt
      Resque.enqueue UpdateDHCPConfigJob
      Resque.enqueue UpdatePXELinkJob, host.id

      { id: host.id }
    end

    private
    def get_ip
      ip = IPAddr.new '10.42.100.1'
      last_ip = IPAddr.new '10.42.199.255'

      ip_list = Host.all(fields: [ :ip ]).map(&:ip)
      until ip == last_ip
        break unless ip_list.include? ip
        ip = ip.succ
      end

      raise 'All IP addresses taken.' if ip == last_ip

      ip
    end
  end

end; end

