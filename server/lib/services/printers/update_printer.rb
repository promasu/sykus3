require 'common'

require 'jobs/printers/update_printer_job'

module Sykus; module Printers

  # Updates a Printer.
  class UpdatePrinter < ServiceBase

    # @param [Integer] id Printer ID.
    # @param [Hash] args Hash of new printer attributes. 
    def action(id, args)
      enforce_permission! :printers_write

      printer = Printer.get(id.to_i)
      raise Exceptions::NotFound, 'Printer not found' if printer.nil?

      printer.attributes = select_args(args, [ :name, :url, :driver ])

      ValidPrinterURL.enforce! printer.url

      drivers = JSON.parse (REDIS.get('Printers.drivers') || '[]'), 
        symbolize_names: true
      if drivers.select { |d| d[:id] == printer.driver } == []
        raise Exceptions::Input, 'Invalid driver'
      end

      if args[:host_groups].is_a? Array
        printer.host_groups = []

        args[:host_groups].each do |pid|
          hg = Hosts::HostGroup.get pid.to_i
          raise Exceptions::Input, 'Host group not found' if hg.nil?
          printer.host_groups << hg
        end
      end

      validate_entity! printer

      printer.save
      entity_evt = EntityEvent.new(EntitySet.new(Printer), printer.id, false)
      EntityEventStore.save entity_evt
      Resque.enqueue UpdatePrinterJob, printer.id
      nil
    end
  end

end; end

