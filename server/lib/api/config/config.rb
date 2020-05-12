require 'common'

require 'services/config/get_config'
require 'services/config/set_config'

module Sykus; module Api

  class App
    get '/config/' do
      exception_wrapper do
        Config::GetConfig.new(get_identity).run.to_json
      end
    end

    post '/config/' do
      exception_wrapper do
        Config::SetConfig.new(get_identity).run(json_request)
        204
      end
    end
  end

end; end

