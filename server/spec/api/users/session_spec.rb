require 'spec_helper'

require 'services/users/create_session'

require 'api/main'

module Sykus

  describe 'Users::Session API' do
    def app; Sykus::Api::App; end

    let (:identity) { IdentityAnonymous.new } 
    let (:create_session) { Users::CreateSession.new identity }

    let (:password) { 'bigbadmama' }
    let (:password_sha) { Digest::SHA256.hexdigest password }
    let (:user) { Factory Users::User, password_sha256: password_sha }

    let (:host) { Factory Hosts::Host }

    let (:data) {{ 
      username: user.username, 
      password: password,
    }}

    context 'POST /sessions/' do
      it 'creates a session' do
        post '/sessions/', data.to_json

        last_response.status.should == 201
        res = json_response
        res[:id].should be_a String
        res[:id].length.should > 10

        session = Users::Session.get(res[:id])
        session.should_not be_nil
        session.host.should be_nil
      end

      it 'creates a session with host' do
        current_session.header 'X-Forwarded-For', host.ip.to_s
        data[:host_login] = true
        post '/sessions/', data.to_json

        last_response.status.should == 201
        res = json_response
        res[:id].should be_a String
        res[:id].length.should > 10

        session = Users::Session.get(res[:id])
        session.should_not be_nil
        session.host.should == host
      end

      it 'fails on invalid data' do
        data[:password] = 'badwolf'
        post '/sessions/', data.to_json

        last_response.status.should == 404
      end
    end

    context 'GET /sessions/:id/keepalive' do
      subject { create_session.run data }

      it 'refreshes the session' do
        get '/sessions/' + subject[:id] + '/keepalive'

        last_response.status.should == 204
      end

      it 'fails on invalid session' do
        get '/sessions/' + ('a' * 64) + '/keepalive'

        last_response.status.should == 404
      end
    end

    context 'DELETE /sessions/:id' do
      subject { create_session.run data }

      it 'deletes the session' do
        delete '/sessions/' + subject[:id]

        last_response.status.should == 204
        Users::Session.get(subject[:id]).should be_nil
      end
    end
  end

end

