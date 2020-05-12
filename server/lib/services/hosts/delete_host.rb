require 'common'

require 'jobs/hosts/update_dhcp_config_job'

module Sykus; module Hosts

  # Deletes a Host.
  class DeleteHost < ServiceBase

    # @param [Integer] id Host ID.
    def action(id)
      enforce_permission! :hosts_update_delete

      host = Host.get id.to_i
      raise Exceptions::NotFound, 'Host not found' if host.nil?

      #      host.sessions.destroy

      host.destroy
      entity_evt = EntityEvent.new(EntitySet.new(Host), id.to_i, true)
      EntityEventStore.save entity_evt
      Resque.enqueue UpdateDHCPConfigJob
      nil
    end
  end

end; end

