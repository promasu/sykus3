require 'common'


require 'jobs/printers/reset_printer_job'

module Sykus; module Printers

  # Resets a printer.
  class ResetPrinter < ServiceBase

    # @param [Integer] id Printer ID
    def action(id)
      enforce_permission! :printers_reset

      printer = Printer.get(id.to_i)
      raise Exceptions::NotFound, 'Printer not found' if printer.nil?

      Resque.enqueue ResetPrinterJob, printer.id
      nil
    end
  end

end; end

