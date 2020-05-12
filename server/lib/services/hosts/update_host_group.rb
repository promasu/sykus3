require 'common'


module Sykus; module Hosts

  # Updates a Host Group.
  class UpdateHostGroup < ServiceBase

    # @param [Integer] id Host group ID.
    # @param [Hash] args Hash of new host group attributes. 
    def action(id, args)
      enforce_permission! :host_groups_write

      hg = HostGroup.get(id.to_i)
      raise Exceptions::NotFound, 'Host Group not found' if hg.nil?

      hg.attributes = select_args(args, [ :name ])

      validate_entity! hg

      hg.save
      entity_evt = EntityEvent.new(EntitySet.new(HostGroup), hg.id, false)
      EntityEventStore.save entity_evt
      nil
    end
  end

end; end

