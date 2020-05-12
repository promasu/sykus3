require 'common'

require 'services/common/get_entity_events'
require 'services/calendar/find_resource'
require 'services/calendar/create_resource'
require 'services/calendar/update_resource'
require 'services/calendar/delete_resource'

module Sykus; module Api

  class App
    get '/calendar/resources/' do
      exception_wrapper do
        Calendar::FindResource.new(get_identity).all.to_json
      end
    end

    get %r{^/calendar/resources/(\d+)$} do |id|
      exception_wrapper do
        Calendar::FindResource.new(get_identity).by_id(id).to_json
      end
    end

    get %r{^/calendar/resources/diff/(-?\d+\.?\d*)$} do |timestamp|
      exception_wrapper do
        events = GetEntityEvents.new(get_identity).
          get_events(EntitySet.new(Calendar::Resource), timestamp)
        events[:updated].map! do |id|
          Calendar::FindResource.new(get_identity).by_id(id)
        end
        events.to_json
      end
    end

    post '/calendar/resources/' do 
      exception_wrapper do
        [ 
          201, 
          Calendar::CreateResource.new(get_identity).run(json_request).to_json 
        ]
      end
    end

    put %r{^/calendar/resources/(\d+)$} do |id|
      exception_wrapper do
        Calendar::UpdateResource.new(get_identity).run(id, json_request)
        204
      end
    end

    delete %r{^/calendar/resources/(\d+)$} do |id|
      exception_wrapper do
        Calendar::DeleteResource.new(get_identity).run(id)
        204
      end
    end
  end

end; end

