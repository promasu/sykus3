require 'common'


require 'services/users/auth'

module Sykus; module Api

  class App
    post '/auth/' do
      exception_wrapper do
        Users::Auth.new(IdentityAnonymous.new).
          run(json_request, get_ip).to_json
      end
    end
  end

end; end

