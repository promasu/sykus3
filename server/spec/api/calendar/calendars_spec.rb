require 'spec_helper'

require 'services/calendar/find_calendars'

require 'api/main'

module Sykus

  describe 'Calendar::Calendars API' do
    def app; Sykus::Api::App; end

    let (:user) { Factory Users::User }
    let (:identity) { create_identity_with_user user }

    let (:find_calendars) { Calendar::FindCalendars.new identity }

    before :each do
      login_with_user user
    end

    context 'GET /calendar/calendars/' do
      it 'returns correct list' do
        get '/calendar/calendars/'

        last_response.should be_ok
        last_response.body.should == find_calendars.all.to_json
      end
    end
  end

end

