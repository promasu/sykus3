require 'common'

require 'jobs/printers/reset_printer_job'

module Sykus; module Teacher

  # Sets Roomctl flags.
  class SetRoomctl < ServiceBase
    # Flag expire timeout.
    TIMEOUT = 120

    # @param [Integer] hg Host Group id.
    # @param [Hash] args Hash of flags.
    def run(hg, args)
      enforce_permission! :teacher_roomctl

      hg = hg.to_i
      unless Hosts::HostGroup.get(hg)
        raise Exceptions::NotFound, 'Invalid host group' 
      end

      %w{screenlock weblock printerlock soundlock}.each do |type|
        next if args[type.to_sym].nil?

        key = "Roomctl.#{hg}.#{type}"
          if args[type.to_sym]
            # reset only on change
            reset_printers hg unless REDIS.get key

            REDIS.set key, '1'
            REDIS.expire key, TIMEOUT
          else
            REDIS.del key
          end
      end

      nil
    end

    private 
    def reset_printers(hg_id)
      Hosts::HostGroup.get(hg_id).printers.each do |printer|
        Resque.enqueue Printers::ResetPrinterJob, printer.id
      end
    end
  end

end; end

