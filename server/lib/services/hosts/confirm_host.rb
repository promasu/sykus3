require 'common'

require 'jobs/hosts/update_pxe_link_job'

module Sykus; module Hosts

  # Confirms installation of host image.
  class ConfirmHost < ServiceBase

    # The image has been installed on the specified host.
    # @param [IPAddr] ip Host IP address.
    # @param [Hash] args Host MAC + hardware spec hash.
    def run(ip, args)
      # no permission enforcement since there is no user logged in

      raise Exceptions::Input unless ip.is_a? IPAddr
      host = Host.first(ip: ip)
      raise Exceptions::NotFound, 'Host not found' if host.nil?
      raise Exceptions::Input, 'Host is ready' if host.ready

      raise Exceptions::Input if args[:cpu_speed].nil? || args[:ram_mb].nil?
      if args[:mac].downcase != host.mac
        raise Exceptions::Input, 'MAC mismatch'
      end

      host.ready = true
      host.cpu_speed = args[:cpu_speed].to_s.to_i
      host.ram_mb = args[:ram_mb].to_s.to_i

      host.save
      entity_evt = EntityEvent.new(EntitySet.new(Host), host.id, false)
      EntityEventStore.save entity_evt
      Resque.enqueue UpdatePXELinkJob, host.id
      nil
    end
  end

end; end

