require 'spec_helper'

require 'services/logs/find_logs'

module Sykus

  describe Logs::FindLogs do
    let (:find_logs) { Logs::FindLogs.new IdentityTestGod.new }

    context 'permission violations' do
      it 'raises on #service_logs' do
        check_service_permission(:logs_read, Logs::FindLogs, :service_logs)
      end

      it 'raises on #session_logs' do
        check_service_permission(:logs_read, Logs::FindLogs, :session_logs)
      end
    end

    context 'service logs' do
      it 'returns all service logs' do
        data = {
          username: 'user42',
          service: 'curry36',
          input: 'in',
          output: 'out',
        }

        Logs::ServiceLog.create data 

        res = find_logs.service_logs
        res.should be_a Array
        res.count.should == 1

        ref = res.first
        ref[:id].should be_a Integer
        ref[:created_at].should be_a String
        ref.delete :id
        ref.delete :created_at
        ref.should == data
      end

      it 'returns all service logs since timestamp' do
        Factory Logs::ServiceLog, created_at: Time.now - 2
        ts = Time.now.to_f

        Factory Logs::ServiceLog
        find_logs.service_logs(ts).count.should == 1
      end

      it 'returns nothing with timestamp zero' do
        Factory Logs::ServiceLog, created_at: Time.now - 2
        Factory Logs::ServiceLog

        find_logs.service_logs(0).count.should == 0
      end
    end

    context 'session logs' do
      it 'returns all session logs' do
        data = {
          username: 'user42',
          type: :login,
          ip: IPAddr.new('10.42.200.1'),
        }

        Logs::SessionLog.create data 

        res = find_logs.session_logs
        res.should be_a Array
        res.count.should == 1

        ref = res.first
        ref[:id].should be_a Integer
        ref[:created_at].should be_a String

        ref[:ip].should == data[:ip].to_s
        ref[:type].should == :login
        ref[:username].should == 'user42'
      end

      it 'returns all session logs since timestamp' do
        Factory Logs::SessionLog, created_at: Time.now - 2
        ts = Time.now.to_f

        Factory Logs::SessionLog
        find_logs.session_logs(ts).count.should == 1
      end

      it 'returns nothing with timestamp zero' do 
        Factory Logs::SessionLog, created_at: Time.now - 2
        Factory Logs::SessionLog

        find_logs.session_logs(0).count.should == 0
      end
    end
  end

end

