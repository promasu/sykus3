require 'common'

module Sykus; module Printers

  # Clears all print jobs.
  class ClearAllJobsJob
    extend Resque::Plugins::Lock
    @queue = :fast

    # Runs the job.
    def self.perform
      system "sudo stop cups"
      system "sudo rm -f /var/spool/cups/*"
      system "sudo start cups"
    end
  end

end; end

