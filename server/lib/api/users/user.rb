require 'common'


require 'services/common/get_entity_events'
require 'services/users/find_user'
require 'services/users/find_username'
require 'services/users/create_user'
require 'services/users/update_user'
require 'services/users/delete_user'
require 'services/users/password_reset'


module Sykus; module Api

  class App
    get '/users/' do
      exception_wrapper do
        Users::FindUser.new(get_identity).all.to_json
      end
    end

    get %r{^/users/(\d+)$} do |id|
      exception_wrapper do
        Users::FindUser.new(get_identity).by_id(id).to_json
      end
    end

    get %r{^/users/([a-z]+[0-9]*)$} do |username|
      exception_wrapper do
        Users::FindUser.new(get_identity).by_name(username).to_json
      end
    end

    get %r{^/users/diff/(-?\d+\.?\d*)$} do |timestamp|
      exception_wrapper do
        events = GetEntityEvents.new(get_identity).
          get_events(EntitySet.new(Users::User), timestamp)
        events[:updated].map! do |id|
          Users::FindUser.new(get_identity).by_id(id)
        end
        events.to_json
      end
    end

    post '/users/' do
      exception_wrapper do
        [ 201, Users::CreateUser.new(get_identity).run(json_request).to_json ]
      end
    end

    post '/users/username/' do
      exception_wrapper do
        Users::FindUsername.new(get_identity).run(json_request).to_json
      end
    end

    post %r{^/users/(\d+)/passwordreset$} do |id|
      exception_wrapper do
        Users::PasswordReset.new(get_identity).run(id).to_json
      end
    end

    put %r{^/users/(\d+)$} do |id|
      exception_wrapper do
        Users::UpdateUser.new(get_identity).run(id, json_request)
        204
      end
    end

    delete %r{^/users/(\d+)$} do |id|
      exception_wrapper do
        Users::DeleteUser.new(get_identity).run(id)
        204
      end
    end
  end

end; end
