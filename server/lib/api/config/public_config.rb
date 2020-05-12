require 'common'

require 'services/config/get_public_config'

module Sykus; module Api

  class App
    get '/config/public/' do
      exception_wrapper do
        identity = IdentityAnonymous.new
        Config::GetPublicConfig.new(identity).run(get_ip(false)).to_json
      end
    end
  end

end; end

