require 'spec_helper'

require 'services/hosts/delete_host_group'

module Sykus

  describe Hosts::DeleteHostGroup do
    let (:identity) { IdentityTestGod.new } 
    let (:delete_host_group) { Hosts::DeleteHostGroup.new identity }

    let (:hg) { Factory Hosts::HostGroup }

    context 'input parameters' do
      it 'works with host group id' do
        delete_host_group.run hg.id

        Hosts::HostGroup.get(hg.id).should be_nil
        check_entity_evt(EntitySet.new(Hosts::HostGroup), hg.id, true)
      end

      it 'works if there are still hosts in group' do
        host = Factory Hosts::Host, host_group: hg

        delete_host_group.run hg.id

        Hosts::HostGroup.get(hg.id).should be_nil
        Hosts::Host.get(host.id).should be_nil
      end

      it 'works if there are printers with that hostgroup' do
        printer = Factory Printers::Printer, host_groups: [ hg ]

        delete_host_group.run hg.id

        Hosts::HostGroup.get(hg.id).should be_nil
        Printers::Printer.get(printer.id).should_not be_nil
      end

    end

    context 'errors' do
      it 'raises on permission violation' do
        check_service_permission(:host_groups_write, 
                                 Hosts::DeleteHostGroup, :run, hg.id)
      end

      it 'raises on invalid id' do
        expect {
          delete_host_group.run 4200
        }.to raise_error Exceptions::NotFound
      end
    end
  end

end

