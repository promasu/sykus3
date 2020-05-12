require 'spec_helper'

require 'jobs/webfilter/update_nonstudents_list_job'

module Sykus

  describe Webfilter::UpdateNonStudentsListJob do
    include FakeFS::SpecHelpers

    file = Webfilter::UpdateNonStudentsListJob::LIST_FILE

    let! (:h1) { Factory Hosts::Host, ip: IPAddr.new('10.42.100.1') }
    let! (:h2) { Factory Hosts::Host, ip: IPAddr.new('10.42.100.2') }
    let! (:h3) { Factory Hosts::Host, ip: IPAddr.new('10.42.100.3') }

    let! (:u1) { Factory Users::User, position_group: :student }
    let! (:u2) { Factory Users::User, position_group: :teacher }
    let! (:u3) { Factory Users::User, position_group: :person }
    let! (:u4) { Factory Users::User, position_group: :person }

    let! (:s1) { Factory Users::Session, user: u1, host: h1 }
    let! (:s2) { Factory Users::Session, user: u1, host: nil, ip: h2.ip }
    let! (:s3) { Factory Users::Session, user: u2, host: h2 }
    let! (:s4) { 
      Factory Users::Session, user: u3, host: nil, 
      ip: IPAddr.new('10.42.200.1') 
    }
    let! (:s5) { 
      Factory Users::Session, user: u3, host: nil, 
      ip: IPAddr.new('192.168.2.1') 
    }

    before :each do
      FileUtils.mkdir_p File.dirname(file)
    end

    it 'updates the ip list' do
      job = Webfilter::UpdateNonStudentsListJob

      job.should_receive(:system).once.with 'sudo squid3 -k reconfigure'

      job.perform

      File.read(file).strip.split("\n").should =~
      [ '10.42.200.1', '10.42.100.2' ]  
    end
  end

end

