require 'spec_helper'

require 'services/calendar/find_resource'
require 'services/calendar/create_resource'

require 'api/main'

module Sykus

  describe 'Calendar::Resource API' do
    def app; Sykus::Api::App; end

    let (:identity) { IdentityTestGod.new } 

    let (:find_resource) { Calendar::FindResource.new identity }
    let (:create_resource) { Calendar::CreateResource.new identity }

    let (:owner) { Factory Calendar::User }
    let (:member) { Factory Calendar::User }
    let (:res1) {{
      name: 'Good Resource',
      active: true,
    }}

    let (:res1_id) { create_resource.run(res1)[:id] }

    context 'GET /calendar/resources/' do
      it 'returns empty array' do
        get '/calendar/resources/'

        last_response.should be_ok
        last_response.body.should == [].to_json
      end

      it 'returns returns two calendar resources' do
        2.times { Factory Calendar::Resource }
        get '/calendar/resources/'

        last_response.should be_ok
        last_response.body.should == find_resource.all.to_json
      end
    end

    context 'GET /calendar/resources/diff/:timestamp' do
      it 'returns nothing with current time' do
        get '/calendar/resources/diff/' + Time.now.to_f.to_s

        last_response.should be_ok
        res = json_response
        res[:updated].should == []
        res[:deleted].should == []
        res[:timestamp].should be_within(0.5).of Time.now.to_f
      end

      it 'returns resources in diff resultset' do
        ts = Time.now.to_f
        id = res1_id
        get '/calendar/resources/diff/' + ts.to_s

        last_response.should be_ok
        res = json_response
        res[:updated].should == [ find_resource.by_id(id) ]
        res[:deleted].should == []
        res[:timestamp].should be_within(0.5).of Time.now.to_f
      end
    end

    context 'GET /calendar/resources/:id' do
      it 'returns  resource' do
        get '/calendar/resources/' + res1_id.to_s

        last_response.should be_ok
        json_response.should == find_resource.by_id(res1_id)
      end

      it 'fails on invalid id' do
        get '/calendar/resources/42000'

        last_response.status.should == 404
      end
    end


    context 'POST /calendar/resources/' do
      it 'creates a new resource' do
        post '/calendar/resources/', res1.to_json

        last_response.status.should == 201
        res = json_response
        res[:id].should be_a Integer
        find_resource.by_id res[:id]
      end

      it 'fails on invalid data' do
        post '/calendar/resources/', {}.to_json

        last_response.status.should == 400
      end
    end


    context 'PUT /calendar/resources/:id' do
      it 'updates a resource' do
        data = {
          name: 'Bad Resource',
        }.to_json
        put '/calendar/resources/' + res1_id.to_s, data

        last_response.status.should == 204
        res = find_resource.by_id res1_id
        res[:name].should == 'Bad Resource'
      end

      it 'fails on invalid id' do
        put '/calendar/resources/4200', {}.to_json

        last_response.status.should == 404
      end
    end

    context 'DELETE /calendar/resources/:id' do
      it 'deletes a resource' do
        delete '/calendar/resources/' + res1_id.to_s

        last_response.status.should == 204
      end

      it 'fails on invalid data' do
        delete '/calendar/resources/4200'

        last_response.status.should == 404
      end
    end
  end

end

