require 'spec_helper'

require 'services/config/get_public_config'

require 'api/main'

module Sykus

  describe 'Config::GetPublicConfig API' do
    def app; Sykus::Api::App; end

    let (:identity) { IdentityTestGod.new } 
    let (:get_public_config) { Config::GetPublicConfig.new identity }
    let (:host) { Factory Hosts::Host }
    let (:ip) { host.ip }

    before (:each) { Timecop.freeze }
    after (:each) { Timecop.return }

    context 'GET /config/public/' do
      it 'returns correct data (with host)' do
        current_session.header 'X-Forwarded-For', ip.to_s 
        get '/config/public/'

        last_response.should be_ok
        last_response.body.should == get_public_config.run(ip).to_json
      end

      it 'returns correct data (without host)' do
        get '/config/public/'

        last_response.should be_ok
        last_response.body.should == get_public_config.run(nil).to_json
      end
    end
  end

end

