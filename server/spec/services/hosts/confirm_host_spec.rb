require 'spec_helper'

require 'services/hosts/confirm_host'
require 'jobs/hosts/update_pxe_link_job'

module Sykus

  describe Hosts::ConfirmHost do
    let (:identity) { IdentityTestGod.new } 
    let (:confirm_host) { Hosts::ConfirmHost.new identity } 

    let (:ready) { false }
    let (:host) { Factory Hosts::Host, ready: ready }
    let (:id) { host.id }
    let (:data) {{
      # must work with mixed case
      mac: host.mac.upcase,
      cpu_speed: 120,
      ram_mb: 512,
    }}

    it 'works with all attributes' do
      confirm_host.run host.ip, data

      ref = Hosts::Host.get id
      ref.ready.should be_true
      ref.cpu_speed.should == 120
      ref.ram_mb.should == 512

      check_entity_evt(EntitySet.new(Hosts::Host), id, false)
    end

    context 'when already ready' do
      let (:ready) { true }
      it 'raises' do
        expect {
          confirm_host.run host.ip, data
        }.to raise_error Exceptions::Input
      end
    end

    context 'errors' do
      it 'raises when given invalid mac' do
        data[:mac] = 'de:ad:be:ef:ca:fe'
        expect {
          confirm_host.run host.ip, data
        }.to raise_error Exceptions::Input
      end

      it '#run raises on invalid ip' do
        expect {
          confirm_host.run IPAddr.new('10.1.1.1'), data
        }.to raise_error Exceptions::NotFound
      end
      end
    end

end

