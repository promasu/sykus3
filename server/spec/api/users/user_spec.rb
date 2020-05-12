require 'spec_helper'

require 'services/users/find_user'
require 'services/users/create_user'

require 'api/main'

module Sykus

  describe 'Users::User API' do
    def app; Sykus::Api::App; end

    let (:identity) { IdentityTestGod.new } 

    let (:find_user) { Users::FindUser.new identity }
    let (:create_user) { Users::CreateUser.new identity }

    let (:johndoe) {{
      first_name: 'John',
      last_name: 'Doe',
      username: 'doejohn',
      birthdate: '11.05.2001',
      position_group: :person,
      admin_group: :none,
    }}

    let (:johndoe_id) { create_user.run(johndoe)[:id] }

    context 'GET /users/' do
      it 'returns empty array' do
        get '/users/'

        last_response.should be_ok
        last_response.body.should == [].to_json
      end

      it 'returns returns two users' do
        2.times { Factory Users::User }
        get '/users/'

        last_response.should be_ok
        last_response.body.should == find_user.all.to_json
      end
    end

    context 'GET /users/diff/:timestamp' do
      it 'returns nothing with current time' do
        get '/users/diff/' + Time.now.to_f.to_s

        last_response.should be_ok
        res = json_response
        res[:updated].should == []
        res[:deleted].should == []
        res[:timestamp].should be_within(0.5).of Time.now.to_f
      end

      it 'returns user in diff resultset' do
        ts = Time.now.to_f
        id = johndoe_id
        get '/users/diff/' + ts.to_s

        last_response.should be_ok
        res = json_response
        res[:updated].should == [ find_user.by_id(id) ]
        res[:deleted].should == []
        res[:timestamp].should be_within(0.5).of Time.now.to_f
      end
    end

    context 'GET /users/:id' do
      it 'returns user' do
        get '/users/' + johndoe_id.to_s

        last_response.should be_ok
        json_response.should == find_user.by_id(johndoe_id)
      end

      it 'fails on invalid id' do
        get '/users/42000'

        last_response.status.should == 404
      end
    end

    context 'GET /users/:username' do
      it 'returns user' do
        get '/users/' + find_user.by_id(johndoe_id)[:username]

        last_response.should be_ok
        json_response.should == find_user.by_id(johndoe_id)
      end

      it 'fails on invalid name' do
        get '/users/invalidname'

        last_response.status.should == 404
      end
    end


    context 'POST /users/' do
      it 'creates a new user' do
        post '/users/', johndoe.to_json

        last_response.status.should == 201
        res = json_response
        res[:id].should be_a Integer
        find_user.by_id res[:id]
      end

      it 'fails on invalid data' do
        post '/users/', {}.to_json

        last_response.status.should == 400
      end
    end

    context 'POST /users/username/' do
      it 'returns a correct username' do
        data = {
          first_name: 'John',
          last_name: 'Doe',
        }.to_json
        post '/users/username/', data

        last_response.should be_ok
        res = json_response
        res[:username].should == 'doejohn'
      end

      it 'returns a correct username with ref id' do
        data = {
          ref_id: johndoe_id,
          first_name: 'John',
          last_name: 'Doe',
        }.to_json
        post '/users/username/', data

        last_response.should be_ok
        res = json_response
        res[:username].should == 'doejohn'
      end


      it 'returns false on invalid data' do
        post '/users/username/', {}.to_json

        last_response.should be_ok
        res = json_response
        res[:username].should == false
      end
    end

    context 'POST /users/:id/passwordreset' do
      it 'resets the password properly' do
        post '/users/' + johndoe_id.to_s + '/passwordreset'

        last_response.should be_ok
        res = json_response
        res[:password].should be_a String
        res[:password].length.should > 5
      end

      it 'fails on invalid user id' do
        post '/users/4200/passwordreset'

        last_response.status.should == 404
      end
    end

    context 'PUT /users/:id' do
      it 'updates a user' do
        data = {
          first_name: 'First',
          last_name: 'Last'
        }.to_json
        put '/users/' + johndoe_id.to_s, data

        last_response.status.should == 204
        user = find_user.by_id johndoe_id
        user[:first_name].should == 'First'
      end

      it 'fails on invalid id' do
        put '/users/4200', {}.to_json

        last_response.status.should == 404
      end

      it 'fails on invalid data' do
        data = {
          first_name: '',
          last_name: ''
        }.to_json
        put '/users/' + johndoe_id.to_s, data

        last_response.status.should == 400
      end
    end

    context 'DELETE /users/:id' do
      it 'deletes a user' do
        delete '/users/' + johndoe_id.to_s

        last_response.status.should == 204
      end

      it 'fails on invalid data' do
        delete '/users/4200'

        last_response.status.should == 404
      end
    end
  end

end

