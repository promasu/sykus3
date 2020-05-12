require 'spec_helper'

require 'api/main'

module Sykus

  class MyApp < Api::App
    get '/get_ip' do
      exception_wrapper do
        get_ip.to_s
      end
    end

    post '/test' do
      exception_wrapper do
        ref = {
          bla: '123',
          blu: 12,
        }

        raise unless json_request == ref
      end
    end
  end

  describe 'Sykus::Api::App Helpers' do
    def app; MyApp; end

    context '#json_request' do
      it 'returns the json data in symbolized key hash' do
        data = {
          bla: '123',
          blu: 12,
        }
        post '/test', data.to_json

        last_response.should be_ok
      end

      it 'raises input error on invalid json' do
        post '/test', '{fla:flu[}'

          last_response.status.should == 400
      end
    end

    context '#get_ip' do
      it 'returns correct ip' do
        current_session.header 'X-Forwarded-For', '10.11.12.13'
        get '/get_ip'

        last_response.should be_ok
        last_response.body.should == '10.11.12.13'
      end

      it 'raises if header cannot be found' do
        get '/get_ip'

        last_response.status.should == 400
      end
    end
  end

end

