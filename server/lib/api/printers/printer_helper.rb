require 'common'


require 'services/printers/printer_helper'

module Sykus; module Api

  class App
    get '/printers/discovered/' do
      exception_wrapper do
        Printers::PrinterHelper.new(get_identity).discovered.to_json
      end
    end

    get '/printers/drivers/' do
      exception_wrapper do
        Printers::PrinterHelper.new(get_identity).drivers.to_json
      end
    end
  end

end; end

