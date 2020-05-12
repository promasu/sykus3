require 'common'

require 'jobs/hosts/update_dhcp_config_job'

module Sykus; module Hosts

  # Updates a Host.
  class UpdateHost < ServiceBase

    # @param [Integer] id Host ID.
    # @param [Hash] args Hash of new host attributes. 
    def action(id, args)
      enforce_permission! :hosts_update_delete

      host = Host.get(id.to_i)
      raise Exceptions::NotFound, 'Host not found' if host.nil?

      host.attributes = select_args(args, [ :name ])
      if args[:host_group]
        host_group = HostGroup.get(args[:host_group].to_i)
        raise Exceptions::NotFound, 'HostGroup not found' if host_group.nil?
        host.host_group = host_group
      end

      validate_entity! host

      host.save
      entity_evt = EntityEvent.new(EntitySet.new(Host), host.id, false)
      EntityEventStore.save entity_evt
      Resque.enqueue UpdateDHCPConfigJob
      nil
    end
  end

end; end

