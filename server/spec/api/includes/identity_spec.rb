require 'spec_helper'

require 'api/main'

require 'services/users/create_session'

module Sykus

  class MyApp < Api::App
    get '/test' do
      exception_wrapper do
        identity = get_identity(true)
        raise unless identity.is_a? IdentityUser
      end
    end

    get '/snitest' do
      sni_exception_wrapper do
        identity = sni_get_identity
        raise unless identity.is_a? IdentityUser
        'ok'
      end
    end

    get '/test/test_id' do
      exception_wrapper do
        identity = get_identity
        raise unless identity.is_a? IdentityTestGod
      end
    end
  end

  describe 'Sykus::Api::App Identity Management' do
    def app; MyApp; end

    let (:user) { Factory Users::User }
    let (:session) { create_session_with_user user }

    before :each do
      clear_cookies
    end

    context 'User Identity' do
      it 'works with a valid session' do
        set_cookie 'session_id=' + session[:id]
        get '/test'

        last_response.should be_ok
      end

      it 'fails with an invalid session' do
        set_cookie 'session_id=' + 'a' * 64
        get '/test'

        last_response.status.should == 401
      end

      it 'fails with an no session' do
        get '/test'

        last_response.status.should == 401
      end
    end

    context 'SNI User Identity' do
      it 'works with a valid session' do
        get '/snitest', { session: session[:id] }

        last_response.should be_ok
        last_response.body.should == 'ok'
      end

      it 'fails with an invalid session' do
        get '/snitest', { session: 'fake' }

        last_response.should be_ok
        last_response.body.should == 'err:invalidsession'
      end

      it 'fails with an no session' do
        get '/snitest'

        last_response.should be_ok
        last_response.body.should == 'err:invalidsession'
      end
    end

    context 'Test God Identity' do
      it 'returns a test identity' do
        get '/test/test_id'

        last_response.should be_ok
      end
    end

  end

end

