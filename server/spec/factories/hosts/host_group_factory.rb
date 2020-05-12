require 'common'

module Sykus

  Factory.define Hosts::HostGroup do |host_group|
    host_group.name 'cluster%d'
  end

end

