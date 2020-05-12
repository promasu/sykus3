require 'spec_helper'

require 'services/dashboards/get_user_dashboard'

require 'api/main'

module Sykus

  describe 'GET /dashboards/users/' do
    def app; Sykus::Api::App; end

    let (:user) { Factory Users::User }
    let (:session) { Factory Users::Session, user: user }
    let (:id) { IdentityTestGod.new }

    before :each do
      id.user_id = user.id
    end

    before :each do
      clear_cookies
    end

    it 'returns correct dashboard data' do
      set_cookie 'session_id=' + session.id
      get '/dashboards/user/'

      last_response.should be_ok
      json_response.should == Dashboards::GetUserDashboard.new(id).run
    end

    it 'fails with an invalid session' do
      get '/dashboards/users/'

      last_response.status.should == 404
    end
  end

end

