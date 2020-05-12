require 'common'

module Sykus

  Factory.define Hosts::Host do |host|
    host.name 'cube%d'
    host.ip '10.42.100.%d'
    host.mac { (1..6).to_a.map { "%02x" % rand(255) }.join(':') }
    host.host_group { Factory Hosts::HostGroup } 
  end

end

