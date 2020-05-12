require 'spec_helper'

require 'jobs/logs/delete_old_logs_job'

module Sykus

  describe Logs::DeleteOldLogsJob do
    let! (:session_log_old) { 
      Factory Logs::SessionLog, created_at: DateTime.now - 15
    }
    let! (:session_log_new) { 
      Factory Logs::SessionLog, created_at: DateTime.now - 10
    }

    let! (:service_log_old) { 
      Factory Logs::ServiceLog, created_at: DateTime.now - 80
    }
    let! (:service_log_new) { 
      Factory Logs::ServiceLog, created_at: DateTime.now - 50
    }

    it 'deletes old log entries' do
      Logs::DeleteOldLogsJob.perform

      Logs::SessionLog.get(session_log_old.id).should be_nil
      Logs::SessionLog.get(session_log_new.id).should_not be_nil

      Logs::ServiceLog.get(service_log_old.id).should be_nil
      Logs::ServiceLog.get(service_log_new.id).should_not be_nil
    end
  end

end

