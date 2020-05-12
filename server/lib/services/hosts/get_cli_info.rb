require 'common'


module Sykus; module Hosts

  # Gets client host info (printers + roomctl screenlock).
  class GetCliInfo < ServiceBase

    # @param [IPAddr] ip Client IP.
    # @return [Hash] Hash of client info.
    def run(ip)
      host = Host.first(ip: ip)
      raise Exceptions::Input, 'Host not found' if host.nil?

      printers = host.host_group.printers.map do |printer|
        { 
          id: "p#{printer.id}",
          name: printer.name.gsub(' ', '-').gsub('/', '-').gsub('#', '')
        }
      end

      data = { printers: printers }
      %w{screenlock printerlock weblock soundlock}.each do |lock|
        data[lock.to_sym] = 
          !!REDIS.get("Roomctl.#{host.host_group.id}.#{lock}")
      end

      data  
    end
  end

end; end

