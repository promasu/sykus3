require 'spec_helper'

require 'services/calendar/find_event'
require 'services/calendar/create_event'

require 'api/main'

module Sykus

  describe 'Calendar::Event API' do
    def app; Sykus::Api::App; end

    let (:user) { Factory Users::User, id: 1 }
    let (:identity) { create_identity_with_user user }

    let (:find_event) { Calendar::FindEvent.new identity }
    let (:create_event) { Calendar::CreateEvent.new identity }

    let (:event1) {{
      title: 'Good Guys',
      start: 123,
      :end => 234,
      cal_id: 'private:1',
      all_day: false,
    }}

    let (:event1_id) { create_event.run(event1)[:id] }

    before :each do
      login_with_user user
    end

    context 'GET /calendar/events/:cal_id/' do
      it 'returns empty array' do
        get '/calendar/events/private:1/'

        last_response.should be_ok
        last_response.body.should == [].to_json
      end

      it 'returns returns two global events' do
        2.times { Factory Calendar::Event, type: :global }
        get '/calendar/events/global/'

        last_response.should be_ok
        last_response.body.should == 
          find_event.all_by_cal_id('global').to_json
      end

      it 'returns returns two private:1 private events' do
        2.times { Factory Calendar::Event, type: :private, user: user }
        get "/calendar/events/private:#{user.id}/"

          last_response.should be_ok
        last_response.body.should == 
          find_event.all_by_cal_id("private:#{user.id}").to_json
      end
    end

    context 'GET /calendar/events/:cal_id/diff/:timestamp' do
      it 'returns nothing with current time' do
        get '/calendar/events/private:1/diff/' + Time.now.to_f.to_s

        last_response.should be_ok
        res = json_response
        res[:updated].should == []
        res[:deleted].should == []
        res[:timestamp].should be_within(0.5).of Time.now.to_f
      end

      it 'returns event in diff resultset' do
        ts = Time.now.to_f
        id = event1_id
        get '/calendar/events/private:1/diff/' + ts.to_s

        last_response.should be_ok
        res = json_response
        res[:updated].should == [ find_event.by_id(id) ]
        res[:deleted].should == []
        res[:timestamp].should be_within(0.5).of Time.now.to_f
      end
    end

    context 'GET /calendar/events/:cal_id/:id' do
      it 'returns event' do
        get '/calendar/events/private:1/' + event1_id.to_s

        last_response.should be_ok
        json_response.should == find_event.by_id(event1_id)
      end

      it 'fails on invalid id' do
        get '/calendar/events/private:1/42000'

        last_response.status.should == 404
      end
    end

    context 'POST /calendar/events/:cal_id/' do
      it 'creates a new event' do
        post '/calendar/events/private:1/', event1.to_json

        last_response.status.should == 201
        res = json_response
        res[:id].should be_a Integer
        find_event.by_id res[:id]
      end

      it 'fails on invalid data' do
        post '/calendar/events/private:1/', {}.to_json

        last_response.status.should == 400
      end
    end

    context 'PUT /calendar/events/:cal_id/:id' do
      it 'updates an event' do
        data = {
          title: 'Badass Event',
        }.to_json
        put '/calendar/events/private:1/' + event1_id.to_s, data

        last_response.status.should == 204
        ug = find_event.by_id event1_id
        ug[:title].should == 'Badass Event'
      end

      it 'fails on invalid id' do
        put '/calendar/events/private:1/4200', {}.to_json

        last_response.status.should == 404
      end
    end

    context 'DELETE /calendar/events/:cal_id/:id' do
      it 'deletes an event' do
        delete '/calendar/events/private:1/' + event1_id.to_s

        last_response.status.should == 204
      end

      it 'fails on invalid data' do
        delete '/calendar/events/private:1/4200'

        last_response.status.should == 404
      end
    end
  end

end

