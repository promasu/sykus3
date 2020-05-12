require 'spec_helper'

require 'services/users/auth'

require 'api/main'

module Sykus

  describe 'Users::Auth API' do
    def app; Sykus::Api::App; end

    let (:identity) { IdentityAnonymous.new } 
    let (:auth) { Users::Auth.new identity }

    let (:password) { 'bigbadmama' }
    let (:password_sha) { Digest::SHA256.hexdigest password }
    let (:user) { Factory Users::User, password_sha256: password_sha }

    let (:host) { Factory Hosts::Host }

    let (:data) {{ 
      username: user.username, 
      password: password,
    }}

    context 'POST /auth/' do
      before :each do 
        current_session.header 'X-Forwarded-For', host.ip.to_s
      end

      it 'authenticates a user' do
        post '/auth/', data.to_json

        last_response.should be_ok
        res = json_response

        res.should == auth.run(data, host.ip)
      end

      it 'fails on invalid data' do
        data[:password] = 'badwolf'
        post '/auth/', data.to_json

        last_response.status.should == 404
      end
    end

  end

end

