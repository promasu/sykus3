require 'common'

module Sykus; module Calendar

  # Updates a Resource
  class UpdateResource < ServiceBase

    # @param [Integer] id Resource ID.
    # @param [Hash] args Hash of new resource attributes. 
    def action(id, args)
      resource = Resource.get(id.to_i)
      raise Exceptions::NotFound, 'Resource not found' if resource.nil?

      enforce_permission! :cal_resource_write

      resource.name = args[:name] if args[:name]
      resource.active = args[:active] unless args[:active].nil?

      validate_entity! resource

      resource.save
      entity_evt = EntityEvent.new(EntitySet.new(Resource), resource.id, false)
      EntityEventStore.save entity_evt
      nil
    end
  end

end; end

