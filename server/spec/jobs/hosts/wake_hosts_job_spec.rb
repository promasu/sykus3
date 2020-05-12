require 'spec_helper'

require 'jobs/hosts/wake_hosts_job'

module Sykus

  describe Hosts::WakeHostsJob do
    let! (:ready0) { Factory Hosts::Host, ready: false }
    let! (:ready1) { Factory Hosts::Host, ready: true }

    it 'sends correct packets' do
      job = Hosts::WakeHostsJob

      job.should_receive(:system).with \
        "wakeonlan -i 10.42.255.255 #{ready0.mac} >/dev/null"

      job.perform
    end
  end

end

