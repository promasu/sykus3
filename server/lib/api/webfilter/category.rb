require 'common'


require 'services/common/get_entity_events'
require 'services/webfilter/find_category'
require 'services/webfilter/update_category'


module Sykus; module Api

  class App
    get '/webfilter/categories/' do
      exception_wrapper do
        Webfilter::FindCategory.new(get_identity).all.to_json
      end
    end

    get %r{^/webfilter/categories/(\d+)$} do |id|
      exception_wrapper do
        Webfilter::FindCategory.new(get_identity).by_id(id).to_json
      end
    end

    get %r{^/webfilter/categories/diff/(-?\d+\.?\d*)$} do |timestamp|
      exception_wrapper do
        events = GetEntityEvents.new(get_identity).
          get_events(EntitySet.new(Webfilter::Category), timestamp)
        events[:updated].map! do |id|
          Webfilter::FindCategory.new(get_identity).by_id(id)
        end
        events.to_json
      end
    end

    put %r{^/webfilter/categories/(\d+)$} do |id|
      exception_wrapper do
        Webfilter::UpdateCategory.new(get_identity).run(id, json_request)
        204
      end
    end
  end

end; end

