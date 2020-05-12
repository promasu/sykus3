require 'spec_helper'

require 'api/main'

module Sykus

  describe 'Users::User API' do
    def app; Sykus::Api::App; end

    let (:password) { 'bigbadmama' }
    let (:password_sha) { Digest::SHA256.hexdigest password }
    let (:user) { 
      Factory Users::User, password_expired: true, 
      password_sha256: password_sha 
    }

    let (:data) {{ 
      username: user.username, 
      old_password: password,
      new_password: 'badwolf123',
    }}

    let (:host) { Factory Hosts::Host }

    context 'POST /password/' do
      it 'resets the password properly' do
        current_session.header 'X-Forwarded-For', host.ip.to_s
        post '/password/', data.to_json

        last_response.should be_ok
      end

      it 'resets the password properly for dhcp host' do
        current_session.header 'X-Forwarded-For', '10.42.200.1'
        post '/password/', data.to_json

        last_response.should be_ok
      end

      it 'fails on invalid user data' do
        data[:username] = 'x'
        current_session.header 'X-Forwarded-For', host.ip.to_s
        post '/password/', data.to_json

        last_response.status.should == 404
      end

      it 'fails on invalid ip' do
        current_session.header 'X-Forwarded-For', '10.21.2.1'
        post '/password/', data.to_json

        last_response.status.should == 400
      end
    end
  end 

end

