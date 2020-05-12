require 'spec_helper'

require 'jobs/hosts/ping_hosts_job'

module Sykus

  describe Hosts::PingHostsJob do
    let! (:h1) { 
      Factory Hosts::Host, online: true, ip: IPAddr.new('10.42.100.1') 
    }
    let! (:h2) { 
      Factory Hosts::Host, online: true, ip: IPAddr.new('10.42.100.2') 
    }
    let! (:h3) { 
      Factory Hosts::Host, online: false, ip: IPAddr.new('10.42.100.3')
    }

    let (:response) {
      "PING 10.42.255.255\n" +
      "64 bytes from 10.42.100.1: icmp_req=1 ttl=64 time=0.500ms\n" +
      "64 bytes from 10.42.100.3: icmp_req=1 ttl=64 time=0.500ms\n" 
    }

    it 'updates hosts correctly' do
      job = Hosts::PingHostsJob

      cmd = 'ping -c2 -b 10.42.255.255 2>/dev/null'
      job.should_receive(:`).with(cmd).and_return(response)
      job.perform

      h1.reload.online.should == true
      h2.reload.online.should == false
      h3.reload.online.should == true

      check_no_entity_evt(EntitySet.new(Hosts::Host), h1.id)
      check_entity_evt(EntitySet.new(Hosts::Host), h2.id, false)
      check_entity_evt(EntitySet.new(Hosts::Host), h3.id, false)
    end
  end

end

