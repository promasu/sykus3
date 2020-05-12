require 'common'


module Sykus; module Printers

  # Gets discovered printers and printer drivers.
  class PrinterHelper < ServiceBase

    # Return list of printer drivers.
    # @return [Array] Printer driver info.
    def drivers
      enforce_permission! :printers_read
      JSON.parse REDIS.get('Printers.drivers'), symbolize_names: true
    end

    # Return list of discovered printers.
    # @return [Array] Printer info.
    def discovered
      enforce_permission! :printers_read
      JSON.parse (REDIS.get('Printers.discovered') || '[]'), 
        symbolize_names: true
    end
  end

end; end

