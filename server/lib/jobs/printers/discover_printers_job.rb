require 'common'


module Sykus; module Printers

  # Uses SNMP to discover printers on the network.
  class DiscoverPrintersJob
    extend Resque::Plugins::Lock
    @queue = :slow

    # Runs the job.
    def self.perform
      result = `sudo /usr/lib/cups/backend/snmp`.strip

      printers = []
      result.split("\n").each do |line|
        type, url = line.split(' ')
        next unless type == 'network'

        begin
          Printers::ValidPrinterURL.enforce! url
        rescue Exceptions::Input
          next
        end

        name = line.split('"')[1].strip

        printers << { name: name, url: url }
      end

      REDIS.set 'Printers.discovered', printers.to_json
    end
  end

end; end

