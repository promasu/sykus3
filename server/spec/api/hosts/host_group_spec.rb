require 'spec_helper'

require 'services/hosts/find_host_group'
require 'services/hosts/create_host_group'

require 'api/main'

module Sykus

  describe 'Hosts::HostGroup API' do
    def app; Sykus::Api::App; end

    let (:identity) { IdentityTestGod.new } 

    let (:find_host_group) { Hosts::FindHostGroup.new identity }
    let (:create_host_group) { Hosts::CreateHostGroup.new identity }

    let (:owner) { Factory Hosts::Host }
    let (:member) { Factory Hosts::Host }
    let (:nicehosts) {{
      name: 'nicehosts',
    }}

    let (:nicehosts_id) { create_host_group.run(nicehosts)[:id] }

    context 'GET /hostgroups/' do
      it 'returns empty array' do
        get '/hostgroups/'

        last_response.should be_ok
        last_response.body.should == [].to_json
      end

      it 'returns returns two hostgroups' do
        2.times { Factory Hosts::HostGroup }
        get '/hostgroups/'

        last_response.should be_ok
        last_response.body.should == find_host_group.all.to_json
      end
    end

    context 'GET /hostgroups/diff/:timestamp' do
      it 'returns nothing with current time' do
        get '/hostgroups/diff/' + Time.now.to_f.to_s

        last_response.should be_ok
        res = json_response
        res[:updated].should == []
        res[:deleted].should == []
        res[:timestamp].should be_within(0.5).of Time.now.to_f
      end

      it 'returns hostgroup in diff resultset' do
        ts = Time.now.to_f
        id = nicehosts_id
        get '/hostgroups/diff/' + ts.to_s

        last_response.should be_ok
        res = json_response
        res[:updated].should == [ find_host_group.by_id(id) ]
        res[:deleted].should == []
        res[:timestamp].should be_within(0.5).of Time.now.to_f
      end
    end

    context 'GET /hostgroups/:id' do
      it 'returns hostgroup' do
        get '/hostgroups/' + nicehosts_id.to_s

        last_response.should be_ok
        json_response.should == find_host_group.by_id(nicehosts_id)
      end

      it 'fails on invalid id' do
        get '/hostgroups/42000'

        last_response.status.should == 404
      end
    end


    context 'POST /hostgroups/' do
      it 'creates a new hostgroup' do
        post '/hostgroups/', nicehosts.to_json

        last_response.status.should == 201
        res = json_response
        res[:id].should be_a Integer
        find_host_group.by_id res[:id]
      end

      it 'fails on invalid data' do
        post '/hostgroups/', {}.to_json

        last_response.status.should == 400
      end
    end


    context 'PUT /hostgroups/:id' do
      it 'updates a hostgroup' do
        data = {
          name: 'sweethosts',
        }.to_json
        put '/hostgroups/' + nicehosts_id.to_s, data

        last_response.status.should == 204
        ug = find_host_group.by_id nicehosts_id
        ug[:name].should == 'sweethosts'
      end

      it 'fails on invalid id' do
        put '/hostgroups/4200', {}.to_json

        last_response.status.should == 404
      end

      it 'fails on invalid data' do
        data = {
          name: '',
        }.to_json
        put '/hostgroups/' + nicehosts_id.to_s, data

        last_response.status.should == 400
      end
    end

    context 'DELETE /hostgroups/:id' do
      it 'deletes a hostgroup' do
        delete '/hostgroups/' + nicehosts_id.to_s

        last_response.status.should == 204
      end

      it 'fails on invalid data' do
        delete '/hostgroups/4200'

        last_response.status.should == 404
      end
    end
  end

end

