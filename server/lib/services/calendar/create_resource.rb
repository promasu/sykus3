require 'common'

module Sykus; module Calendar

  # Creates a new Resource.
  class CreateResource < ServiceBase

    # @param [Hash] args Hash with name of new resource.
    # @return [Hash/Integer] Resource ID.
    def action(args)
      enforce_permission! :cal_resource_write

      raise Exceptions::Input unless args[:name].is_a? String

      name = args[:name].strip
      resource = Resource.new name: name, active: true

      validate_entity! resource

      resource.save
      entity_evt = EntityEvent.new(EntitySet.new(Resource), resource.id, false)
      EntityEventStore.save entity_evt

      { id: resource.id }
    end
  end

end; end

