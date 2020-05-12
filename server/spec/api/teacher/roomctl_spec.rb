require 'spec_helper'

require 'services/teacher/get_roomctl'

require 'api/main'

module Sykus

  describe 'Teacher::Roomctl API' do
    def app; Sykus::Api::App; end

    let (:identity) { IdentityTestGod.new } 
    let (:get_roomctl) { Teacher::GetRoomctl.new identity }

    let! (:hg) { Factory Hosts::HostGroup }

    context 'GET /roomctl/:id' do
      it 'returns correct data' do
        get '/roomctl/' + hg.id.to_s

        last_response.should be_ok
        last_response.body.should == get_roomctl.run(hg.id).to_json
      end

      it 'fails on invalid hostgroup' do
        get '/roomctl/42'

        last_response.status.should == 404
      end
    end

    context 'POST /roomctl/:id' do
      it 'sets correct data' do
        data = { screenlock: true }
        post '/roomctl/' + hg.id.to_s, data.to_json

        last_response.status.should == 204

        get_roomctl.run(hg.id)[:screenlock].should be_true
      end

      it 'fails on invalid hostgroup' do
        post '/roomctl/42', {}.to_json

        last_response.status.should == 404
      end
    end
  end

end

