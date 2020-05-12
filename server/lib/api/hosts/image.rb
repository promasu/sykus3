require 'common'

require 'services/hosts/create_image'
require 'services/hosts/abort_image'

module Sykus; module Api

  class App
    get '/image' do
      exception_wrapper do
        Hosts::CreateImage.new(IdentityAnonymous.new).state.to_json
      end
    end

    post '/image' do 
      exception_wrapper do
        Hosts::CreateImage.new(get_identity).run(json_request)
        204
      end
    end

    delete '/image' do 
      exception_wrapper do
        Hosts::AbortImage.new(get_identity).run
        204
      end
    end

  end

end; end

