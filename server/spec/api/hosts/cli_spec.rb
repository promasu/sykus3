require 'spec_helper'

require 'services/hosts/get_cli_info'

require 'api/main'

module Sykus

  describe 'Hosts::GetCliInfo API' do
    def app; Sykus::Api::App; end

    let (:identity) { IdentityTestGod.new } 
    let (:get_cli_info) { Hosts::GetCliInfo.new identity }
    let (:host) { Factory Hosts::Host }
    let (:ip) { host.ip }

    context 'GET /cli/' do
      it 'returns correct data' do
        current_session.header 'X-Forwarded-For', ip.to_s 
        get '/cli/'

        last_response.should be_ok
        last_response.body.should == get_cli_info.run(ip).to_json
      end

      it 'fails on invalid host' do
        get '/cli/'

        last_response.status.should == 400
      end
    end

  end

end

