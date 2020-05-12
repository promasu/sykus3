require 'common'


require 'services/common/get_entity_events'
require 'services/users/find_user_class'
require 'services/users/create_user_class'
require 'services/users/delete_user_class'


module Sykus; module Api

  class App
    get '/userclasses/' do
      exception_wrapper do
        Users::FindUserClass.new(get_identity).all.to_json
      end
    end 

    get %r{^/userclasses/(\d+)$} do |id|
      exception_wrapper do
        Users::FindUserClass.new(get_identity).by_id(id).to_json
      end
    end

    get %r{^/userclasses/diff/(-?\d+\.?\d*)$} do |timestamp|
      exception_wrapper do
        events = GetEntityEvents.new(get_identity).
          get_events(EntitySet.new(Users::UserClass), timestamp)
        events[:updated].map! do |id|
          Users::FindUserClass.new(get_identity).by_id(id)
        end
        events.to_json
      end
    end

    post '/userclasses/' do
      exception_wrapper do
        [ 201, Users::CreateUserClass.new(get_identity).
          run(json_request).to_json ]
      end
    end

    delete %r{^/userclasses/(\d+)$} do |id|
      exception_wrapper do
        Users::DeleteUserClass.new(get_identity).run(id)
        204
      end
    end
  end

end; end
