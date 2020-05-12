require 'common'

module Sykus; module Calendar

  # Updates a Event.
  class UpdateEvent < ServiceBase
    # @param [Integer] id Event ID.
    # @param [Hash] args Hash of new event attributes. 
    def action(id, args)
      id = id.to_i
      event = Event.get(id)
      raise Exceptions::NotFound, 'Event not found' if event.nil?

      old_cal_id = event.cal_id

      event.attributes = select_args(args, [ :title, :location, 
                                     :all_day, :cal_id ])

      event.start = Time.at(args[:start]) if args[:start]
      event.end = Time.at(args[:end]) if args[:end]

      validate_entity! event

      perm = CalendarPermission.get(@identity, event.cal_id)
      if event.user.id == @identity.user_id
        unless [ :write, :admin ].include? perm 
          raise Exceptions::Permission, 'Calendar write or admin' 
        end
      else
        raise Exceptions::Permission, 'Calendar admin' unless perm == :admin
      end

      event.save
      entity_evt = EntityEvent.new(EntitySet.new(Event, event.cal_id),
                                   event.id, false)
      EntityEventStore.save entity_evt

      if event.cal_id != old_cal_id
        entity_evt = EntityEvent.new(EntitySet.new(Event, old_cal_id),
                                     event.id, true)
        EntityEventStore.save entity_evt
      end

      nil
    end
  end

end; end

