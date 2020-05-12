require 'spec_helper'

require 'services/printers/find_printer'
require 'services/printers/create_printer'

require 'api/main'

module Sykus

  describe 'Printers::Printer API' do
    def app; Sykus::Api::App; end

    let (:identity) { IdentityTestGod.new } 

    let (:find_printer) { Printers::FindPrinter.new identity }
    let (:create_printer) { Printers::CreatePrinter.new identity }

    let (:printer1) {{
      name: 'Printer 1',
      url: 'socket://10.42.20.1',
      driver: 'foo:matic',
      host_groups: [],
    }}

    let (:printer1_id) { create_printer.run(printer1)[:id] }

    before :each do
      REDIS.set 'Printers.drivers', 
        [ { id: 'foo:matic', name: 'foo' } ].to_json
    end

    context 'GET /printers/' do
      it 'returns empty array' do
        get '/printers/'

        last_response.should be_ok
        last_response.body.should == [].to_json
      end

      it 'returns returns two printers' do
        2.times { Factory Printers::Printer }
        get '/printers/'

        last_response.should be_ok
        last_response.body.should == find_printer.all.to_json
      end
    end

    context 'GET /printers/diff/:timestamp' do
      it 'returns nothing with current time' do
        get '/printers/diff/' + Time.now.to_f.to_s

        last_response.should be_ok
        res = json_response
        res[:updated].should == []
        res[:deleted].should == []
        res[:timestamp].should be_within(0.5).of Time.now.to_f
      end

      it 'returns printer in diff resultset' do
        ts = Time.now.to_f
        id = printer1_id
        get '/printers/diff/' + ts.to_s

        last_response.should be_ok
        res = json_response
        res[:updated].should == [ find_printer.by_id(id) ]
        res[:deleted].should == []
        res[:timestamp].should be_within(0.5).of Time.now.to_f
      end
    end

    context 'GET /printers/:id' do
      it 'returns printer' do
        get '/printers/' + printer1_id.to_s

        last_response.should be_ok
        json_response.should == find_printer.by_id(printer1_id)
      end

      it 'fails on invalid id' do
        get '/printers/42000'

        last_response.status.should == 404
      end
    end


    context 'POST /printers/' do
      it 'creates a new printer' do
        post '/printers/', printer1.to_json

        last_response.status.should == 201
        res = json_response
        res[:id].should be_a Integer
        find_printer.by_id res[:id]
      end

      it 'fails on invalid data' do
        post '/printers/', {}.to_json

        last_response.status.should == 400
      end
    end

    context 'POST /printers/:id/reset' do
      it 'resets the printer properly' do
        post '/printers/' + printer1_id.to_s + '/reset'

        last_response.should be_ok
      end

      it 'fails on invalid printer id' do
        post '/printers/4200/reset'

        last_response.status.should == 404
      end
    end

    context 'PUT /printers/:id' do
      it 'updates a printer' do
        data = {
          name: 'Printer New',
        }.to_json
        put '/printers/' + printer1_id.to_s, data

        last_response.status.should == 204
        printer = find_printer.by_id printer1_id
        printer[:name].should == 'Printer New'
      end

      it 'fails on invalid id' do
        put '/printers/4200', {}.to_json

        last_response.status.should == 404
      end

      it 'fails on invalid data' do
        data = {
          name: '',
        }.to_json
        put '/printers/' + printer1_id.to_s, data

        last_response.status.should == 400
      end
    end

    context 'DELETE /printers/:id' do
      it 'deletes a printer' do
        delete '/printers/' + printer1_id.to_s

        last_response.status.should == 204
      end

      it 'fails on invalid data' do
        delete '/printers/4200'

        last_response.status.should == 404
      end
    end
  end

end

