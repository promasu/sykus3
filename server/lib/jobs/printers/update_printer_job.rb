require 'common'

module Sykus; module Printers

  # Updates or deletes a printer's CUPS config.
  class UpdatePrinterJob
    extend Resque::Plugins::Lock
    @queue = :fast

    # Runs the job.
    # @param [Integer] id Printer ID.
    def self.perform(id)
      printer = Printer.get id

      if printer.nil?
        system "sudo lpadmin -x p#{id.to_i.to_s}"
        return
      end

      driver = Shellwords.shellescape printer.driver
      url = Shellwords.shellescape printer.url

      system "sudo lpadmin -p p#{id.to_i.to_s} -E -m #{driver} -v #{url}"
    end
  end

end; end

