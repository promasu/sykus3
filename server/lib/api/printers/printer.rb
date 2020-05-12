require 'common'


require 'services/common/get_entity_events'
require 'services/printers/find_printer'
require 'services/printers/create_printer'
require 'services/printers/update_printer'
require 'services/printers/delete_printer'
require 'services/printers/reset_printer'

module Sykus; module Api

  class App
    get '/printers/' do
      exception_wrapper do
        Printers::FindPrinter.new(get_identity).all.to_json
      end
    end

    get %r{^/printers/(\d+)$} do |id|
      exception_wrapper do
        Printers::FindPrinter.new(get_identity).by_id(id).to_json
      end
    end

    get %r{^/printers/diff/(-?\d+\.?\d*)$} do |timestamp|
      exception_wrapper do
        events = GetEntityEvents.new(get_identity).
          get_events(EntitySet.new(Printers::Printer), timestamp)
        events[:updated].map! do |id|
          Printers::FindPrinter.new(get_identity).by_id(id)
        end
        events.to_json
      end
    end

    post '/printers/' do
      exception_wrapper do
        [ 201, Printers::CreatePrinter.new(get_identity).
          run(json_request).to_json ]
      end
    end

    post %r{^/printers/(\d+)/reset$} do |id|
      exception_wrapper do
        Printers::ResetPrinter.new(get_identity).run(id).to_json
      end
    end

    put %r{^/printers/(\d+)$} do |id|
      exception_wrapper do
        Printers::UpdatePrinter.new(get_identity).run(id, json_request)
        204
      end
    end

    delete %r{^/printers/(\d+)$} do |id|
      exception_wrapper do
        Printers::DeletePrinter.new(get_identity).run(id)
        204
      end
    end
  end

end; end

