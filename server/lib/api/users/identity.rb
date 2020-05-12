require 'common'


require 'services/users/get_identity'

module Sykus; module Api

  class App
    get '/identity' do
      exception_wrapper do
        Users::GetIdentity.new(get_identity(true)).run.to_json
      end
    end
  end

end; end

