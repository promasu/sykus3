require 'common'

module Sykus; module Hosts

  # Ping hosts and save online/offline state.
  class PingHostsJob
    extend Resque::Plugins::Lock
    @queue = :slow

    # Runs the job.
    def self.perform
      iplist = {}

      # do two requests to catch all responses from first request
      %x{ping -c2 -b 10.42.255.255 2>/dev/null}.split("\n").each do |line|
        split = line.split(' ')
        next unless split[4] == 'icmp_req=1'

        ip = split[3][0..-2]
        iplist[ip] = true
      end

      Hosts::Host.each do |host|
        state = !!iplist[host.ip.to_s]
        next if host.online == state

        host.online = state
        host.save

        entity_evt = EntityEvent.new(EntitySet.new(Host), host.id, false)
        EntityEventStore.save entity_evt
      end

      end
    end

  end; end

