require 'common'

require 'services/hosts/delete_host'

module Sykus; module Hosts

  # Deletes a Host Group.
  class DeleteHostGroup < ServiceBase

    # @param [Integer] id Host group ID.
    def action(id)
      enforce_permission! :host_groups_write

      hg = HostGroup.get(id.to_i)
      raise Exceptions::NotFound, 'Host group not found' if hg.nil?

      hosts = Hosts::Host.all host_group: hg
      if hosts.size > 0
        delete_host = DeleteHost.new(@identity)
        hosts.each do |host|
          delete_host.run host.id
        end
      end

      # clear many-to-many relationship
      hg.printers = []
      hg.save

      hg.destroy
      entity_evt = EntityEvent.new(EntitySet.new(HostGroup), id.to_i, true)
      EntityEventStore.save entity_evt
    end
  end

end; end

