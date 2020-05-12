require 'common'

module Sykus; module Config

  # Gets public config information.
  class GetPublicConfig < ServiceBase

    # @param [IPAddr] ip Remote IP.
    # @return [Hash] Hash of config data.
    def run(ip)
      if ip
        net_cli = ip > IPAddr.new('10.42.100.0') && 
          ip < IPAddr.new('10.42.199.255')

        net_int = IPAddr.new('10.42.0.0/16').include? ip

        host = Hosts::Host.first(ip: ip) if net_cli
      end

      {
        demo: !!ConfigValue.get('demo'),
        app_env: APP_ENV,
        school_name: ConfigValue.get('school_name') || '(set up school name)',

        servertime: Time.now.to_i,

        hostname: (host ? "#{host.host_group.name}-#{host.name}" : ''),
        net_int: !!net_int,
        net_cli: !!(net_cli && host),
        host_ready: !!(host && host.ready),
        host_group: (host ? host.host_group.id : nil),
      }
    end
  end

end; end

