require 'spec_helper'

require 'services/teacher/set_roomctl'

module Sykus

  describe Teacher::SetRoomctl do
    let (:identity) { IdentityTestGod.new } 
    let (:set_roomctl) { Teacher::SetRoomctl.new identity }

    let! (:hg) { Factory Hosts::HostGroup }
    let! (:hg2) { Factory Hosts::HostGroup }
    let! (:p1) { Factory Printers::Printer, host_groups: [ hg ] }
    let! (:p2) { Factory Printers::Printer, host_groups: [ hg ] }
    let! (:p3) { Factory Printers::Printer, host_groups: [ hg2 ] }

    context 'enable all flags' do
      it 'returns correct values' do
        set_roomctl.run hg.id, 
          screenlock: true, weblock: true, printerlock: true, soundlock: true

        REDIS.get('Roomctl.1.screenlock').should == '1'
        REDIS.get('Roomctl.1.weblock').should == '1'
        REDIS.get('Roomctl.1.printerlock').should == '1'
        REDIS.get('Roomctl.1.soundlock').should == '1'

        REDIS.ttl('Roomctl.1.screenlock').should == 
          Teacher::SetRoomctl::TIMEOUT
        REDIS.ttl('Roomctl.1.weblock').should ==
          Teacher::SetRoomctl::TIMEOUT
        REDIS.ttl('Roomctl.1.printerlock').should ==
          Teacher::SetRoomctl::TIMEOUT
        REDIS.ttl('Roomctl.1.soundlock').should ==
          Teacher::SetRoomctl::TIMEOUT

      end
    end

    context 'disable all flags' do
      before :each do 
        REDIS.set('Roomctl.1.screenlock', '1')
        REDIS.set('Roomctl.1.weblock', '1')
        REDIS.set('Roomctl.1.printerlock', '1')
        REDIS.set('Roomctl.1.soundlock', '1')
      end

      it 'returns correct values' do
        set_roomctl.run hg.id,
          screenlock: false, weblock: false, 
          printerlock: false, soundlock: false

        REDIS.get('Roomctl.1.screenlock').should be_nil
        REDIS.get('Roomctl.1.weblock').should be_nil
        REDIS.get('Roomctl.1.printerlock').should be_nil
        REDIS.get('Roomctl.1.soundlock').should be_nil
      end
    end

    context 'no flags' do
      before :each do 
        REDIS.set('Roomctl.1.screenlock', '1')
      end

      it 'returns correct values' do
        set_roomctl.run hg.id, {}

        REDIS.get('Roomctl.1.screenlock').should == '1'
        REDIS.get('Roomctl.1.weblock').should be_nil
        REDIS.get('Roomctl.1.printerlock').should be_nil
        REDIS.get('Roomctl.1.soundlock').should be_nil
      end
    end

    context 'printer reset' do
      it 'resets printers on change to locked' do
        set_roomctl.run hg.id, printerlock: true

        Resque.dequeue(Printers::ResetPrinterJob, p1.id).should == 1
        Resque.dequeue(Printers::ResetPrinterJob, p2.id).should == 1
        Resque.dequeue(Printers::ResetPrinterJob).should == 0
      end

      it 'does nothing if already locked' do
        REDIS.set('Roomctl.1.printerlock', '1')
        set_roomctl.run hg.id, printerlock: true

        Resque.dequeue(Printers::ResetPrinterJob).should == 0
      end
    end

    context 'with invalid host group' do
      it 'raises' do
        expect {
          set_roomctl.run 42, {}
        }.to raise_error Exceptions::NotFound
      end
    end

    context 'permission violations' do
      it 'raises on #run' do
        check_service_permission(:teacher_roomctl, 
                                 Teacher::SetRoomctl, :run, 42, {})
      end
    end
  end

end

