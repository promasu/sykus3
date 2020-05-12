require 'common'

module Sykus; module Logs

  # Deletes old log entries.
  class DeleteOldLogsJob
    extend Resque::Plugins::Lock
    @queue = :slow

    # Time after which session logs expire.
    SESSION_LOG_EXPIRE_DAYS = 14

    # Time after which service logs expire.
    SERVICE_LOG_EXPIRE_DAYS = 60

    # Runs the job.
    def self.perform
      ref = DateTime.now - SESSION_LOG_EXPIRE_DAYS
      SessionLog.all(:created_at.lt => ref).destroy

      ref = DateTime.now - SERVICE_LOG_EXPIRE_DAYS
      ServiceLog.all(:created_at.lt => ref).destroy
    end
  end

end; end

