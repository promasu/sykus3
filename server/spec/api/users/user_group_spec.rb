require 'spec_helper'

require 'services/users/find_user_group'
require 'services/users/create_user_group'

require 'api/main'

module Sykus

  describe 'Users::UserGroup API' do
    def app; Sykus::Api::App; end

    let (:identity) { IdentityTestGod.new } 

    let (:find_user_group) { Users::FindUserGroup.new identity }
    let (:create_user_group) { Users::CreateUserGroup.new identity }

    let (:owner) { Factory Users::User }
    let (:member) { Factory Users::User }
    let (:goodguys) {{
      name: 'Good Guys',
      owner: owner.id,
      users: [ member.id ],
    }}

    let (:goodguys_id) { create_user_group.run(goodguys)[:id] }

    context 'GET /usergroups/' do
      it 'returns empty array' do
        get '/usergroups/'

        last_response.should be_ok
        last_response.body.should == [].to_json
      end

      it 'returns returns two usergroups' do
        2.times { Factory Users::UserGroup }
        get '/usergroups/'

        last_response.should be_ok
        last_response.body.should == find_user_group.all.to_json
      end
    end

    context 'GET /usergroups/diff/:timestamp' do
      it 'returns nothing with current time' do
        get '/usergroups/diff/' + Time.now.to_f.to_s

        last_response.should be_ok
        res = json_response
        res[:updated].should == []
        res[:deleted].should == []
        res[:timestamp].should be_within(0.5).of Time.now.to_f
      end

      it 'returns usergroup in diff resultset' do
        ts = Time.now.to_f
        id = goodguys_id
        get '/usergroups/diff/' + ts.to_s

        last_response.should be_ok
        res = json_response
        res[:updated].should == [ find_user_group.by_id(id) ]
        res[:deleted].should == []
        res[:timestamp].should be_within(0.5).of Time.now.to_f
      end
    end

    context 'GET /usergroups/:id' do
      it 'returns usergroup' do
        get '/usergroups/' + goodguys_id.to_s

        last_response.should be_ok
        json_response.should == find_user_group.by_id(goodguys_id)
      end

      it 'fails on invalid id' do
        get '/usergroups/42000'

        last_response.status.should == 404
      end
    end

    context 'GET /usergroups/own/' do
      it 'returns correct own user groups' do
        get '/usergroups/own/'

        # no real identity, so this should fail
        last_response.status.should == 400
      end
    end


    context 'POST /usergroups/' do
      it 'creates a new usergroup' do
        post '/usergroups/', goodguys.to_json

        last_response.status.should == 201
        res = json_response
        res[:id].should be_a Integer
        find_user_group.by_id res[:id]
      end

      it 'fails on invalid data' do
        post '/usergroups/', {}.to_json

        last_response.status.should == 400
      end
    end


    context 'PUT /usergroups/:id' do
      it 'updates a usergroup' do
        data = {
          name: 'Bad Guys',
        }.to_json
        put '/usergroups/' + goodguys_id.to_s, data

        last_response.status.should == 204
        ug = find_user_group.by_id goodguys_id
        ug[:name].should == 'Bad Guys'
      end

      it 'fails on invalid id' do
        put '/usergroups/4200', {}.to_json

        last_response.status.should == 404
      end

      it 'fails on invalid data' do
        data = {
          name: '',
        }.to_json
        put '/usergroups/' + goodguys_id.to_s, data

        last_response.status.should == 400
      end
    end

    context 'DELETE /usergroups/:id' do
      it 'deletes a usergroup' do
        delete '/usergroups/' + goodguys_id.to_s

        last_response.status.should == 204
      end

      it 'fails on invalid data' do
        delete '/usergroups/4200'

        last_response.status.should == 404
      end
    end
  end

end

