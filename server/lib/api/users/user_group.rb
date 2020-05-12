require 'common'


require 'services/common/get_entity_events'
require 'services/users/find_user_group'
require 'services/users/create_user_group'
require 'services/users/update_user_group'
require 'services/users/delete_user_group'


module Sykus; module Api

  class App
    get '/usergroups/' do
      exception_wrapper do
        Users::FindUserGroup.new(get_identity).all.to_json
      end
    end 

    get '/usergroups/own/' do
      exception_wrapper do
        Users::FindUserGroup.new(get_identity).own.to_json
      end
    end

    get %r{^/usergroups/(\d+)$} do |id|
      exception_wrapper do
        Users::FindUserGroup.new(get_identity).by_id(id).to_json
      end
    end

    get %r{^/usergroups/diff/(-?\d+\.?\d*)$} do |timestamp|
      exception_wrapper do
        events = GetEntityEvents.new(get_identity).
          get_events(EntitySet.new(Users::UserGroup), timestamp)
        events[:updated].map! do |id|
          Users::FindUserGroup.new(get_identity).by_id(id)
        end
        events.to_json
      end
    end

    post '/usergroups/' do
      exception_wrapper do
        [ 201, Users::CreateUserGroup.new(get_identity).
          run(json_request).to_json ]
      end
    end

    put %r{^/usergroups/(\d+)$} do |id|
      exception_wrapper do
        Users::UpdateUserGroup.new(get_identity).run(id, json_request)
        204
      end
    end

    delete %r{^/usergroups/(\d+)$} do |id|
      exception_wrapper do
        Users::DeleteUserGroup.new(get_identity).run(id)
        204
      end
    end
  end

end; end
