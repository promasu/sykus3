require 'common'


require 'services/users/create_session'
require 'services/users/keepalive_session'
require 'services/users/delete_session'

module Sykus; module Api

  class App
    post '/sessions/' do
      exception_wrapper do
        result = Users::CreateSession.new(IdentityAnonymous.new).
          run(json_request, false, get_ip(false)).to_json
        [ 201, result ]
      end
    end

    get %r{^/sessions/([a-z0-9]{64})/keepalive$} do |id|
      exception_wrapper do
        Users::KeepaliveSession.new(IdentityAnonymous.new).run(id)
        204
      end
    end

    delete %r{^/sessions/([a-z0-9]{64})$} do |id|
      exception_wrapper do
        Users::DeleteSession.new(IdentityAnonymous.new).run(id)
        204
      end
    end
  end

end; end

