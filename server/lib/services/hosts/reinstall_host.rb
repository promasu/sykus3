require 'common'

require 'jobs/hosts/update_pxe_link_job'

module Sykus; module Hosts

  # Reinstall the host image.
  class ReinstallHost < ServiceBase

    # The image should be re-installed on the specified host.
    # @param [Integer] id Host ID
    def action(id)
      enforce_permission! :hosts_update_delete

      host = Host.get(id.to_i)
      raise Exceptions::NotFound, 'Host not found' if host.nil?

      host.ready = false

      host.save
      entity_evt = EntityEvent.new(EntitySet.new(Host), host.id, false)
      EntityEventStore.save entity_evt
      Resque.enqueue UpdatePXELinkJob, host.id
      nil
    end
  end

end; end

