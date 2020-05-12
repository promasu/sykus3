require 'spec_helper'

require 'jobs/printers/clear_all_jobs_job'

module Sykus

  describe Printers::ClearAllJobsJob do
    it 'resets a printer correctly' do
      job = Printers::ClearAllJobsJob
      job.should_receive(:system).with('sudo stop cups')
      job.should_receive(:system).with('sudo rm -f /var/spool/cups/*')
      job.should_receive(:system).with('sudo start cups')

      job.perform
    end
  end

end

