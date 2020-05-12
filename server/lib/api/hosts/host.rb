require 'common'


require 'services/common/get_entity_events'
require 'services/hosts/find_host'
require 'services/hosts/update_host'
require 'services/hosts/reinstall_host'
require 'services/hosts/delete_host'


module Sykus; module Api

  class App
    get '/hosts/' do
      exception_wrapper do
        Hosts::FindHost.new(get_identity).all.to_json
      end
    end

    get %r{^/hosts/(\d+)$} do |id|
      exception_wrapper do
        Hosts::FindHost.new(get_identity).by_id(id).to_json
      end
    end

    get %r{^/hosts/diff/(-?\d+\.?\d*)$} do |timestamp|
      exception_wrapper do
        events = GetEntityEvents.new(get_identity).
          get_events(EntitySet.new(Hosts::Host), timestamp)
        events[:updated].map! do |id|
          Hosts::FindHost.new(get_identity).by_id(id)
        end
        events.to_json
      end
    end

    post %r{^/hosts/(\d+)/reinstall$} do |id|
      exception_wrapper do
        Hosts::ReinstallHost.new(get_identity).run(id)
        204
      end
    end

    put %r{^/hosts/(\d+)$} do |id|
      exception_wrapper do
        Hosts::UpdateHost.new(get_identity).run(id, json_request)
        204
      end
    end

    delete %r{^/hosts/(\d+)$} do |id|
      exception_wrapper do
        Hosts::DeleteHost.new(get_identity).run(id)
        204
      end
    end
  end

end; end

