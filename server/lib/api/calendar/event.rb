require 'common'

require 'services/common/get_entity_events'
require 'services/calendar/find_event'
require 'services/calendar/create_event'
require 'services/calendar/update_event'
require 'services/calendar/delete_event'

module Sykus; module Api

  class App
    get %r{^/calendar/events/([a-z0-9\:]+)/$} do |cal_id|
      exception_wrapper do
        Calendar::FindEvent.new(get_identity(true)).
          all_by_cal_id(cal_id).to_json
      end
    end

    get %r{^/calendar/events/([a-z0-9\:]+)/(\d+)$} do |cal_id, id|
      exception_wrapper do
        Calendar::FindEvent.new(get_identity(true)).by_id(id).to_json
      end
    end

    get %r{^/calendar/events/([a-z0-9\:]+)/diff/(-?\d+\.?\d*)$} do 
      |cal_id, timestamp|

      exception_wrapper do
        events = GetEntityEvents.new(get_identity).
          get_events(EntitySet.new(Calendar::Event, cal_id), timestamp)
        events[:updated].map! do |id|
          Calendar::FindEvent.new(get_identity(true)).by_id(id)
        end
        events.to_json
      end
    end

    post %r{^/calendar/events/([a-z0-9\:]+)/$} do |cal_id|
      exception_wrapper do
        data = json_request.merge({ cal_id: cal_id })
        [ 201, Calendar::CreateEvent.new(get_identity(true)).
          run(data).to_json ]
      end
    end

    put %r{^/calendar/events/([a-z0-9\:]+)/(\d+)$} do |cal_id, id|
      exception_wrapper do
        Calendar::UpdateEvent.new(get_identity(true)).
          run(id, json_request)
        204
      end
    end

    delete %r{^/calendar/events/([a-z0-9\:]+)/(\d+)$} do |cal_id, id|
      exception_wrapper do
        Calendar::DeleteEvent.new(get_identity(true)).run(id)
        204
      end
    end
  end

end; end

