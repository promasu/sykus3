require 'common'


module Sykus; module Printers

  # Finds Printers.
  class FindPrinter < ServiceBase

    # Find printer given their printer id.
    # @param [Integer] id Printer ID.
    # @return [Hash] Printer data.
    def by_id(id)
      enforce_permission! :printers_read
      export_printer Printer.get(id)
    end

    # Find all printers.
    # @return [Array] Array of printer data.
    def all
      enforce_permission! :printers_read
      Printer.all.map { |printer| export_printer printer }
    end

    private 
    def export_printer(printer)
      raise Exceptions::NotFound, 'Printer not found' if printer.nil?

      data = select_entity_props(printer, [ :id, :name, :driver, :url ]) 

      data.merge({
        host_groups: printer.host_groups.map(&:id),
      })
    end
  end

end; end

