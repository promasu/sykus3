require 'common'

module Sykus; module Calendar

  # Finds Calendar.
  class FindEvent < ServiceBase

    # Find event given their event id.
    # @param [Integer] id Event ID.
    # @return [Hash] Event data.
    def by_id(id)
      event = Event.get(id)
      raise Exceptions::NotFound, 'Event not found' if event.nil?

      perm = CalendarPermission.get(@identity, event.cal_id)
      raise Exceptions::Permission, 'Calendar read' if perm == :none

      export_event event
    end

    # Find all events for a given calendar ID.
    # @param [String] cal_id Calendar ID.
    # @return [Array] Array of event data.
    def all_by_cal_id(cal_id)
      perm = CalendarPermission.get(@identity, cal_id)
      raise Exceptions::Permission, 'Calendar read' if perm == :none

      type, id = *cal_id.split(':')
      id = id.to_i

      events = 
        case type.to_sym
        when :global
          Event.all(type: :global)
        when :teacher
          Event.all(type: :teacher)
        when :private
          user = Users::User.get(id)
          Event.all(type: :private, user: user) 
        when :group
          user_group = Users::UserGroup.get(id)
          Event.all(type: :group, user_group: user_group)
        when :grade
          Event.all(type: :grade, grade: id)
        when :class
          user_class = Users::UserClass.get(id)
          Event.all(type: :class, user_class: user_class)
        when :resource
          res = Calendar::Resource.get(id)
          Event.all(type: :resource, resource: res)
        end

      events.map { |event| export_event event }
    end

    private 
    def export_event(event)
      data = select_entity_props(event, [ :id, :title, :location, :all_day ])

      data.merge({
        start: event.start.to_i,
        :end => event.end.to_i,
        created_at: event.created_at.to_i,
        user: event.user.id,
      })
    end
  end

end; end

