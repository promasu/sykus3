require 'common'

require 'jobs/printers/update_printer_job'

module Sykus; module Printers

  # Creates a new Printer.
  class CreatePrinter < ServiceBase

    # @param [Hash] args Hash of new printer attributes. 
    # @return [Hash/Integer] Printer ID.
    def action(args)
      enforce_permission! :printers_write

      printer = Printer.new select_args(args, [ :name, :url, :driver ])

      ValidPrinterURL.enforce! printer.url

      drivers = JSON.parse (REDIS.get('Printers.drivers') || '[]'), 
        symbolize_names: true
      if drivers.select { |d| d[:id] == printer.driver } == []
        raise Exceptions::Input, 'Invalid driver'
      end

      unless args[:host_groups].is_a? Array
        raise Exceptions::Input, 'Host groups must be an array'
      end
      args[:host_groups].each do |id|
        hg = Hosts::HostGroup.get id.to_i
        raise Exceptions::Input, 'Host group not found' if hg.nil?
        printer.host_groups << hg
      end

      validate_entity! printer

      printer.save
      entity_evt = EntityEvent.new(EntitySet.new(Printer), printer.id, false)
      EntityEventStore.save entity_evt
      Resque.enqueue UpdatePrinterJob, printer.id

      { id: printer.id }
    end
  end

end; end

