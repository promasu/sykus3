require 'spec_helper'

require 'services/config/get_config'
require 'services/config/set_config'

require 'api/main'

module Sykus

  describe 'Config::GetConfig/SetConfig API' do
    def app; Sykus::Api::App; end

    let (:identity) { IdentityTestGod.new } 
    let (:get_config) { Config::GetConfig.new identity }

    context 'GET /config/' do
      it 'returns correct data' do
        get '/config/'

        last_response.should be_ok
        last_response.body.should == get_config.run.to_json
      end
    end

    context 'POST /config/' do
      it 'sets correct data' do
        data = { school_name: 'test' }
        post '/config/', data.to_json

        last_response.status.should == 204

        Config::ConfigValue.get('school_name').should == 'test'
      end
    end
  end

end

