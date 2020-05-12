require 'spec_helper'

require 'services/hosts/find_package'
require 'services/hosts/update_package'

require 'api/main'

module Sykus

  describe 'Hosts::Package API' do
    def app; Sykus::Api::App; end

    let (:identity) { IdentityTestGod.new } 

    let (:find_package) { Hosts::FindPackage.new identity }
    let (:update_package) { Hosts::UpdatePackage.new identity }
    let (:pack_id) { Factory.create(Hosts::Package, selected: false).id }

    context 'GET /packages/' do
      it 'returns empty array' do
        get '/packages/'

        last_response.should be_ok
        last_response.body.should == [].to_json
      end

      it 'returns returns two packages' do
        2.times { Factory Hosts::Package }
        get '/packages/'

        last_response.should be_ok
        last_response.body.should == find_package.all.to_json
      end
    end

    context 'GET /packages/diff/:timestamp' do
      it 'returns nothing with current time' do
        get '/packages/diff/' + Time.now.to_f.to_s

        last_response.should be_ok
        res = json_response
        res[:updated].should == []
        res[:deleted].should == []
        res[:timestamp].should be_within(0.5).of Time.now.to_f
      end

      it 'returns package in diff resultset' do
        ts = Time.now.to_f
        id = pack_id
        update_package.run id, { selected: true }
        get '/packages/diff/' + ts.to_s

        last_response.should be_ok
        res = json_response
        res[:updated].should == [ find_package.by_id(id) ]
        res[:deleted].should == []
        res[:timestamp].should be_within(0.5).of Time.now.to_f
      end
    end

    context 'GET /packages/:id' do
      it 'returns package' do
        get '/packages/' + pack_id.to_s

        last_response.should be_ok
        json_response.should == find_package.by_id(pack_id)
      end

      it 'fails on invalid id' do
        get '/packages/42000'

        last_response.status.should == 404
      end
    end

    context 'PUT /packages/:id' do
      it 'updates a package' do
        data = {
          selected: true
        }.to_json
        put '/packages/' + pack_id.to_s, data

        last_response.status.should == 204
        package = find_package.by_id pack_id
        package[:selected].should be_true
      end

      it 'fails on invalid id' do
        put '/packages/4200', {}.to_json

        last_response.status.should == 404
      end
    end

  end

end

