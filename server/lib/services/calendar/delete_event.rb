require 'common'

module Sykus; module Calendar

  # Deletes a Event.
  class DeleteEvent < ServiceBase
    # @param [Integer] id Event ID.
    def action(id)
      id = id.to_i
      event = Event.get(id)
      raise Exceptions::NotFound, 'Event not found' if event.nil?

      perm = CalendarPermission.get(@identity, event.cal_id)
      if event.user.id == @identity.user_id
        unless [ :write, :admin ].include? perm 
          raise Exceptions::Permission, 'Calendar write or admin' 
        end
      else
        raise Exceptions::Permission, 'Calendar admin' unless perm == :admin
      end

      event.destroy
      entity_evt = EntityEvent.new(EntitySet.new(Event, event.cal_id), 
                                   id, true)
      EntityEventStore.save entity_evt

      nil
    end
  end

end; end

