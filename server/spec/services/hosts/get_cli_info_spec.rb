require 'spec_helper'

require 'services/hosts/get_cli_info'

module Sykus

  describe Hosts::GetCliInfo do
    let (:identity) { IdentityAnonymous.new } 
    let (:get_cli_info) { Hosts::GetCliInfo.new identity }

    let (:hg) { Factory Hosts::HostGroup }
    let! (:host) { Factory Hosts::Host, host_group: hg }
    let! (:printer) { 
      Factory Printers::Printer, 
      host_groups: [ hg ],
      name: 'Printer Test/1#'
    }

    let (:printername) { 'Printer-Test-1' }

    subject { get_cli_info.run host.ip }

    context 'with no locks and printer' do
      it 'returns correct data' do
        subject.should == {
          printers: [ { name: printername, id: "p#{printer.id}" } ],
          screenlock: false,
          printerlock: false,
          weblock: false,
          soundlock: false,
        }
      end
    end

    context 'with printerlock and printer' do
      before :each do
        REDIS.set("Roomctl.#{hg.id}.printerlock", true)
      end

      it 'returns correct data' do
        subject.should == {
          printers: [ { name: printername, id: "p#{printer.id}" } ],
          printerlock: true,
          weblock: false,
          screenlock: false,
          soundlock: false,
        }
      end
    end

    context 'with all locks and printer' do
      before :each do
        REDIS.set("Roomctl.#{hg.id}.screenlock", true)
          REDIS.set("Roomctl.#{hg.id}.weblock", true)
          REDIS.set("Roomctl.#{hg.id}.printerlock", true)
          REDIS.set("Roomctl.#{hg.id}.soundlock", true)
      end

      it 'returns correct data' do
        subject.should == {
          printers: [ { name: printername, id: "p#{printer.id}" } ],
          screenlock: true,
          weblock: true,
          printerlock: true,
          soundlock: true,
        }
      end
    end

    context 'no printers' do
      before :each do
        printer.host_groups = []
        printer.save
      end

      it 'returns correct data' do
        subject.should == {
          printers: [ ],
          screenlock: false,
          weblock: false,
          printerlock: false,
          soundlock: false,
        }
      end
    end

    context 'invalid host' do
      it 'raises' do
        expect {
          get_cli_info.run '10.42.1.1'
        }.to raise_error Exceptions::Input
      end
    end
  end

end

