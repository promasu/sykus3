require 'common'

require 'jobs/webfilter/update_nonstudents_list_job'

module Sykus; module Users

  # Deletes expired user sessions.
  class CleanSessionsJob
    extend Resque::Plugins::Lock
    @queue = :fast

    # Session expire timeout.
    TIMEOUT = 15

    # Runs the job.
    def self.perform
      result = Session.all(:updated_at.lt => Time.now - TIMEOUT)

      if result.count > 0
        Resque.enqueue Webfilter::UpdateNonStudentsListJob
        result.destroy
      end
    end
  end

end; end

