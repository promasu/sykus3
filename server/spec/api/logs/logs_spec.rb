require 'spec_helper'

require 'api/main'

require 'services/logs/find_logs'

module Sykus

  describe 'Users::User API' do
    def app; Sykus::Api::App; end

    let (:identity) { IdentityTestGod.new } 
    let (:find_logs) { Logs::FindLogs.new identity }

    context 'GET /logs/service/' do
      it 'returns empty array' do
        get '/logs/service/'

        last_response.should be_ok
        last_response.body.should == [].to_json
      end

      it 'returns returns two log entries' do
        2.times { Factory Logs::ServiceLog }
        get '/logs/service/'

        last_response.should be_ok
        last_response.body.should == find_logs.service_logs.to_json
      end
    end

    context 'GET /logs/service/diff/:timestamp' do
      it 'returns nothing with current time' do
        get '/logs/service/diff/' + Time.now.to_f.to_s

        last_response.should be_ok
        res = json_response
        res[:updated].should == []
        res[:deleted].should == []
        res[:timestamp].should be_within(0.5).of Time.now.to_f
      end

      it 'returns log in diff resultset' do
        ts = Time.now.to_f
        log = Factory Logs::ServiceLog
        get '/logs/service/diff/' + ts.to_s

        last_response.should be_ok
        res = json_response
        res[:updated].first[:created_at].should == log.created_at.to_s
        res[:deleted].should == []
        res[:timestamp].should be_within(0.5).of Time.now.to_f
      end
    end

    context 'GET /logs/session/' do
      it 'returns empty array' do
        get '/logs/session/'

        last_response.should be_ok
        last_response.body.should == [].to_json
      end

      it 'returns returns two log entries' do
        2.times { Factory Logs::SessionLog }
        get '/logs/session/'

        last_response.should be_ok
        last_response.body.should == find_logs.session_logs.to_json
      end
    end

    context 'GET /logs/session/diff/:timestamp' do
      it 'returns nothing with current time' do
        get '/logs/session/diff/' + Time.now.to_f.to_s

        last_response.should be_ok
        res = json_response
        res[:updated].should == []
        res[:deleted].should == []
        res[:timestamp].should be_within(0.5).of Time.now.to_f
      end

      it 'returns log in diff resultset' do
        ts = Time.now.to_f
        log = Factory Logs::SessionLog
        get '/logs/session/diff/' + ts.to_s

        last_response.should be_ok
        res = json_response
        res[:updated].first[:created_at].should == log.created_at.to_s
        res[:deleted].should == []
        res[:timestamp].should be_within(0.5).of Time.now.to_f
      end
    end

  end

end

