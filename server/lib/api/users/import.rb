require 'common'


require 'services/users/import_users'


module Sykus; module Api

  class App
    post '/userimport/' do
      exception_wrapper do
        Users::ImportUsers.new(get_identity).run(json_request).to_json
      end
    end 
  end

end; end

