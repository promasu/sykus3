require 'common'

require 'services/calendar/find_calendars'

module Sykus; module Api

  class App
    get '/calendar/calendars/' do
      exception_wrapper do
        Calendar::FindCalendars.new(get_identity(true)).all.to_json
      end
    end

  end

end; end

