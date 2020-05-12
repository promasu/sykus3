require 'common'

module Sykus; module Hosts

  # Sends Wake-on-LAN packets to hosts that are not ready.
  class WakeHostsJob
    extend Resque::Plugins::Lock
    @queue = :slow

    # Runs the job.
    def self.perform
      Host.all(ready: false).each do |host|
        system "wakeonlan -i 10.42.255.255 #{host.mac} >/dev/null"
      end
    end
  end

end; end

