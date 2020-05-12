require 'common'


require 'services/common/get_entity_events'
require 'services/hosts/find_host_group'
require 'services/hosts/create_host_group'
require 'services/hosts/update_host_group'
require 'services/hosts/delete_host_group'


module Sykus; module Api

  class App
    get '/hostgroups/' do
      exception_wrapper do
        Hosts::FindHostGroup.new(get_identity).all.to_json
      end
    end 

    get %r{^/hostgroups/(\d+)$} do |id|
      exception_wrapper do
        Hosts::FindHostGroup.new(get_identity).by_id(id).to_json
      end
    end

    get %r{^/hostgroups/diff/(-?\d+\.?\d*)$} do |timestamp|
      exception_wrapper do
        events = GetEntityEvents.new(get_identity).
          get_events(EntitySet.new(Hosts::HostGroup), timestamp)
        events[:updated].map! do |id|
          Hosts::FindHostGroup.new(get_identity).by_id(id)
        end
        events.to_json
      end
    end

    post '/hostgroups/' do
      exception_wrapper do
        [ 201, Hosts::CreateHostGroup.new(get_identity).
          run(json_request).to_json ]
      end
    end

    put %r{^/hostgroups/(\d+)$} do |id|
      exception_wrapper do
        Hosts::UpdateHostGroup.new(get_identity).run(id, json_request)
        204
      end
    end

    delete %r{^/hostgroups/(\d+)$} do |id|
      exception_wrapper do
        Hosts::DeleteHostGroup.new(get_identity).run(id)
        204
      end
    end
  end

end; end

