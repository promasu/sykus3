require 'spec_helper'

require 'api/main'

module Sykus

  describe 'Printers::PrinterHelper API' do
    def app; Sykus::Api::App; end

    let (:drivers) {
      [ { id: 'foo:matic', name: 'foo' } ]
    }

    let (:discovered) {
      [ { name: 'Printer 1', url: 'socket://10.42.20.1' } ]
    }

    before :each do
      REDIS.set 'Printers.drivers', drivers.to_json
      REDIS.set 'Printers.discovered', discovered.to_json
    end

    context 'GET /printers/drivers/' do
      it 'returns driver array' do
        get '/printers/drivers/'

        last_response.should be_ok
        last_response.body.should == drivers.to_json
      end
    end 

    context 'GET /printers/discovered/' do
      it 'returns discovered printer array' do
        get '/printers/discovered/'

        last_response.should be_ok
        last_response.body.should == discovered.to_json
      end
    end
  end

end

