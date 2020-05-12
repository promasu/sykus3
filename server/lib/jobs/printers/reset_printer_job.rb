require 'common'

module Sykus; module Printers

  # Reactivates a stalled printer and deletes all jobs.
  class ResetPrinterJob
    extend Resque::Plugins::Lock
    @queue = :fast

    # Runs the job.
    # @param [Integer] id Printer ID.
    def self.perform(id)
      system "sudo cupsenable -c p#{id.to_i}"
    end
  end

end; end

