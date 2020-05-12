require 'spec_helper'

require 'services/hosts/create_host_group'

module Sykus

  describe Hosts::CreateHostGroup do
    let (:identity) { IdentityTestGod.new } 
    let (:create_host_group) { Hosts::CreateHostGroup.new identity }

    let (:grp) {{ name: 'nicehosts' }}

    subject { create_host_group.run grp }

    it 'works with all required parameters' do
      result = subject 
      id = result[:id]
      id.should be_a Integer

      hg = Hosts::HostGroup.get id
      hg.name.should == grp[:name]

      check_entity_evt(EntitySet.new(Hosts::HostGroup), id, false)
    end

    context 'errors' do
      it '#run raises on permission violation' do
        check_service_permission(:host_groups_write, 
                                 Hosts::CreateHostGroup, :run, grp)
      end

      it "raises if name is missing" do
        grp.delete :name

        expect { subject }.to raise_error Exceptions::Input
      end
    end
  end

end

