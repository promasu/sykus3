require 'spec_helper'

require 'services/users/find_user_class'
require 'services/users/create_user_class'

require 'api/main'

module Sykus

  describe 'Users::UserClass API' do
    def app; Sykus::Api::App; end

    let (:identity) { IdentityTestGod.new } 

    let (:find_user_class) { Users::FindUserClass.new identity }
    let (:create_user_class) { Users::CreateUserClass.new identity }

    let (:classy) {{ name: '7c' }}
    let (:classy_id) { create_user_class.run(classy)[:id] }

    context 'GET /userclasses/' do
      it 'returns empty array' do
        get '/userclasses/'

        last_response.should be_ok
        last_response.body.should == [].to_json
      end

      it 'returns returns two classes' do
        2.times { Factory Users::UserClass }
        get '/userclasses/'

        last_response.should be_ok
        last_response.body.should == find_user_class.all.to_json
      end
    end

    context 'GET /userclasses/diff/:timestamp' do
      it 'returns nothing with current time' do
        get '/userclasses/diff/' + Time.now.to_f.to_s

        last_response.should be_ok
        res = json_response
        res[:updated].should == []
        res[:deleted].should == []
        res[:timestamp].should be_within(0.5).of Time.now.to_f
      end

      it 'returns userclass in diff resultset' do
        ts = Time.now.to_f
        id = classy_id
        get '/userclasses/diff/' + ts.to_s

        last_response.should be_ok
        res = json_response
        res[:updated].should == [ find_user_class.by_id(id) ]
        res[:deleted].should == []
        res[:timestamp].should be_within(0.5).of Time.now.to_f
      end
    end

    context 'GET /userclasses/:id' do
      it 'returns user class' do
        get '/userclasses/' + classy_id.to_s

        last_response.should be_ok
        json_response.should == find_user_class.by_id(classy_id)
      end

      it 'fails on invalid id' do
        get '/userclasses/42000'

        last_response.status.should == 404
      end
    end


    context 'POST /userclasses/' do
      it 'creates a new user class' do
        post '/userclasses/', classy.to_json

        last_response.status.should == 201
        res = json_response
        res[:id].should be_a Integer
        find_user_class.by_id res[:id]
      end

      it 'fails on invalid data' do
        post '/userclasses/', {}.to_json

        last_response.status.should == 400
      end
    end


    context 'DELETE /userclasses/:id' do
      it 'deletes a user class' do
        delete '/userclasses/' + classy_id.to_s

        last_response.status.should == 204
      end

      it 'fails on invalid data' do
        delete '/userclasses/4200'

        last_response.status.should == 404
      end
    end
  end

end

