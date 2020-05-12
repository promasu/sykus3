require 'common'

require 'services/hosts/get_cli_info'

module Sykus; module Api

  class App
    get '/cli/' do
      exception_wrapper do
        identity = IdentityAnonymous.new
        Hosts::GetCliInfo.new(identity).run(get_ip).to_json
      end
    end
  end

end; end

