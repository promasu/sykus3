require 'common'


require 'services/common/get_entity_events'
require 'services/hosts/find_package'
require 'services/hosts/update_package'


module Sykus; module Api

  class App
    get '/packages/' do
      exception_wrapper do
        Hosts::FindPackage.new(get_identity).all.to_json
      end
    end

    get %r{^/packages/(\d+)$} do |id|
      exception_wrapper do
        Hosts::FindPackage.new(get_identity).by_id(id).to_json
      end
    end

    get %r{^/packages/diff/(-?\d+\.?\d*)$} do |timestamp|
      exception_wrapper do
        events = GetEntityEvents.new(get_identity).
          get_events(EntitySet.new(Hosts::Package), timestamp)
        events[:updated].map! do |id|
          Hosts::FindPackage.new(get_identity).by_id(id)
        end
        events.to_json
      end
    end

    put %r{^/packages/(\d+)$} do |id|
      exception_wrapper do
        Hosts::UpdatePackage.new(get_identity).run(id, json_request)
        204
      end
    end
  end

end; end

