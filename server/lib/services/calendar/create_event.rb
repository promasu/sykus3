require 'common'

module Sykus; module Calendar

  # Creates a new Event.
  class CreateEvent < ServiceBase
    # @param [Hash] args Hash of new event attributes. 
    # @return [Hash/Integer] Event ID.
    def action(args)
      event = Event.new select_args(args, [ :title, :location, 
                                    :all_day, :cal_id ])

      event.start = Time.at(args[:start] || 0)
      event.end = Time.at(args[:end] || 0)

      event.user = Users::User.get(@identity.user_id)

      validate_entity! event

      perm = CalendarPermission.get(@identity, event.cal_id)
      unless [ :write, :admin ].include? perm 
        raise Exceptions::Permission, 'Calendar write or admin' 
      end

      event.save
      entity_evt = EntityEvent.new(EntitySet.new(Event, event.cal_id), 
                                   event.id, false)
      EntityEventStore.save entity_evt

      { id: event.id }
    end
  end

end; end

