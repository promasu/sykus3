require 'spec_helper'

require 'services/hosts/find_host'
require 'services/hosts/create_host'

require 'api/main'

module Sykus

  describe 'Hosts::Host API' do
    def app; Sykus::Api::App; end

    let (:identity) { IdentityTestGod.new } 

    let (:find_host) { Hosts::FindHost.new identity }
    let (:create_host) { Hosts::CreateHost.new identity }

    let (:nicehosts) { Factory Hosts::HostGroup }

    let (:glados) {{
      name: 'glados',
      mac: '00:1c:de:ad:be:ef',
      host_group: nicehosts.id,
    }}

    let (:glados_id) { create_host.run(glados)[:id] }

    context 'GET /hosts/' do
      it 'returns empty array' do
        get '/hosts/'

        last_response.should be_ok
        last_response.body.should == [].to_json
      end

      it 'returns returns two hosts' do
        2.times { Factory Hosts::Host }
        get '/hosts/'

        last_response.should be_ok
        last_response.body.should == find_host.all.to_json
      end
    end

    context 'GET /hosts/diff/:timestamp' do
      it 'returns nothing with current time' do
        get '/hosts/diff/' + Time.now.to_f.to_s

        last_response.should be_ok
        res = json_response
        res[:updated].should == []
        res[:deleted].should == []
        res[:timestamp].should be_within(0.5).of Time.now.to_f
      end

      it 'returns host in diff resultset' do
        ts = Time.now.to_f
        id = glados_id
        get '/hosts/diff/' + ts.to_s

        last_response.should be_ok
        res = json_response
        res[:updated].should == [ find_host.by_id(id) ]
        res[:deleted].should == []
        res[:timestamp].should be_within(0.5).of Time.now.to_f
      end
    end

    context 'GET /hosts/:id' do
      it 'returns host' do
        get '/hosts/' + glados_id.to_s

        last_response.should be_ok
        json_response.should == find_host.by_id(glados_id)
      end

      it 'fails on invalid id' do
        get '/hosts/42000'

        last_response.status.should == 404
      end
    end

    context 'POST /hosts/:id/reinstall' do
      it 'reinstalls a host' do
        post '/hosts/' + glados_id.to_s + '/reinstall'

        last_response.status.should == 204
        host = find_host.by_id glados_id
        host[:ready].should be_false
      end

      it 'fails on invalid id' do
        post '/hosts/4200/reinstall'

        last_response.status.should == 404
      end
    end

    context 'PUT /hosts/:id' do
      it 'updates a host' do
        data = {
          name: 'wheatley',
        }.to_json
        put '/hosts/' + glados_id.to_s, data

        last_response.status.should == 204
        host = find_host.by_id glados_id
        host[:name].should == 'wheatley'
      end

      it 'fails on invalid id' do
        put '/hosts/4200', {}.to_json

        last_response.status.should == 404
      end

      it 'fails on invalid data' do
        data = {
          name: '',
        }.to_json
        put '/hosts/' + glados_id.to_s, data

        last_response.status.should == 400
      end
    end

    context 'DELETE /hosts/:id' do
      it 'deletes a host' do
        delete '/hosts/' + glados_id.to_s

        last_response.status.should == 204
      end

      it 'fails on invalid data' do
        delete '/hosts/4200'

        last_response.status.should == 404
      end
    end
  end

end

