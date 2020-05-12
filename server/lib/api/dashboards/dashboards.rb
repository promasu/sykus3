require 'common'

require 'services/dashboards/get_user_dashboard'

module Sykus; module Api

  class App
    get '/dashboards/user/' do
      exception_wrapper do
        Dashboards::GetUserDashboard.new(get_identity(true)).run.to_json
      end
    end 
  end

end; end

