require 'common'


require 'services/users/change_password'

module Sykus; module Api

  class App
    post '/password/' do
      exception_wrapper do
        Users::ChangePassword.new(IdentityAnonymous.new).
          run(json_request, get_ip).to_json
      end
    end
  end

end; end

