require 'common'

require 'services/common/get_entity_events'
require 'services/webfilter/find_entry'
require 'services/webfilter/create_entry'
require 'services/webfilter/delete_entry'

module Sykus; module Api

  class App
    get '/webfilter/entries/' do
      exception_wrapper do
        Webfilter::FindEntry.new(get_identity).all.to_json
      end
    end

    get %r{^/webfilter/entries/(\d+)$} do |id|
      exception_wrapper do
        Webfilter::FindEntry.new(get_identity).by_id(id).to_json
      end
    end

    get %r{^/webfilter/entries/diff/(-?\d+\.?\d*)$} do |timestamp|
      exception_wrapper do
        events = GetEntityEvents.new(get_identity).
          get_events(EntitySet.new(Webfilter::Entry), timestamp)
        events[:updated].map! do |id|
          Webfilter::FindEntry.new(get_identity).by_id(id)
        end
        events.to_json
      end
    end

    post '/webfilter/entries/' do
      exception_wrapper do
        [ 
          201, 
          Webfilter::CreateEntry.new(get_identity).run(json_request).to_json 
        ]
      end
    end

    delete %r{^/webfilter/entries/(\d+)$} do |id|
      exception_wrapper do
        Webfilter::DeleteEntry.new(get_identity).run(id)
        204
      end
    end
  end

end; end

