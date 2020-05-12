require 'common'

module Sykus; module Calendar

  # Deletes a Resource.
  class DeleteResource < ServiceBase

    # @param [Integer] id Resource ID.
    def action(id)
      enforce_permission! :cal_resource_write

      resource = Resource.get(id.to_i)
      raise Exceptions::NotFound, 'Resource not found' if resource.nil?

      # clear calendar events
      resource.events.destroy

      resource.destroy
      entity_evt = EntityEvent.new(EntitySet.new(Resource), id.to_i, true)
      EntityEventStore.save entity_evt
    end
  end

end; end

