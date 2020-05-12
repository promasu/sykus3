require 'common'

require 'jobs/printers/update_printer_job'

module Sykus; module Printers

  # Deletes a Printer.
  class DeletePrinter < ServiceBase

    # @param [Integer] id Printer ID.
    def action(id)
      enforce_permission! :printers_write

      printer = Printer.get id.to_i
      raise Exceptions::NotFound, 'Printer not found' if printer.nil?

      # clear many-to-many relationship
      printer.host_groups = []
      printer.save

      printer.destroy
      entity_evt = EntityEvent.new(EntitySet.new(Printer), id.to_i, true)
      EntityEventStore.save entity_evt
      Resque.enqueue UpdatePrinterJob, printer.id
      nil
    end
  end

end; end

