require 'spec_helper'

require 'api/main'

require 'services/users/create_session'

module Sykus

  describe 'GET /identity' do
    def app; Sykus::Api::App; end

    let (:user) { Factory Users::User }
    let (:session) { create_session_with_user user }

    before :each do
      clear_cookies
    end

    it 'returns correct identity' do
      set_cookie 'session_id=' + session[:id]
      get '/identity'

      last_response.should be_ok
      res = json_response

      res[:user][:username].should == user.username
      res[:permissions].count.should > 0
      res[:permissions].each do |perm|
        Config::Permissions::PermissionList.should include perm.to_sym
      end
    end

    it 'fails with an invalid session' do
      get '/identity'

      last_response.status.should == 401
    end
  end

end

