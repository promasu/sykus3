require 'common'


module Sykus; module Hosts

  # Finds Hosts.
  class FindHost < ServiceBase

    # Find host given their host id.
    # @param [Integer] id Host ID.
    # @return [Hash] Host data.
    def by_id(id)
      enforce_permission! :hosts_read
      export_host Host.get(id)
    end

    # Find all hosts.
    # @return [Array] Array of host data.
    def all
      enforce_permission! :hosts_read
      Host.all.map { |host| export_host host }
    end

    private 
    def export_host(host)
      raise Exceptions::NotFound, 'Host not found' if host.nil?

      data = select_entity_props(host, [ :id, :name, :mac, :online, :ready, 
                                 :cpu_speed, :ram_mb ])

      data.merge({ 
        host_group: host.host_group.id,
        ip: host.ip.to_s,
      })
    end
  end

end; end

