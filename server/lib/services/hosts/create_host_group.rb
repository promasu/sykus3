require 'common'


module Sykus; module Hosts

  # Creates a new Host Group.
  class CreateHostGroup < ServiceBase

    # @param [Hash] args Hash with name of new host group.
    # @return [Hash/Integer] Host Group ID.
    def action(args)
      enforce_permission! :host_groups_write

      raise Exceptions::Input unless args[:name].is_a? String

      hg = HostGroup.new name: args[:name].strip

      validate_entity! hg

      hg.save
      entity_evt = EntityEvent.new(EntitySet.new(HostGroup), hg.id, false)
      EntityEventStore.save entity_evt

      { id: hg.id }
    end
  end

end; end

