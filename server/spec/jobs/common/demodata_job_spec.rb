require 'spec_helper'

require 'jobs/common/demodata_job'

module Sykus

  describe DemoDataJob do
    it 'creates demodata', slow: true do
      DemoDataJob.perform

      [ 
        Users::UserGroup, Users::UserClass,
        Hosts::HostGroup, Hosts::Package,
        Printers::Printer, Webfilter::Entry, Calendar::Event
      ].each do |entity|
        entity.count.should > 1
      end

      [ 
        Users::User, Hosts::Host
      ].each do |entity|
        entity.count.should > 10
      end
    end
  end

end

