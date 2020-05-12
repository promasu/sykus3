require 'spec_helper'

require 'services/hosts/update_host_group'

module Sykus

  describe Hosts::UpdateHostGroup do
    let (:identity) { IdentityTestGod.new } 
    let (:update_host_group) { Hosts::UpdateHostGroup.new identity } 

    let (:hg) { Factory Hosts::HostGroup }

    let (:grp) {{ name: 'nicehosts' }}

    context 'input parameters' do
      it 'works with all attributes' do
        update_host_group.run(hg.id, grp)

        ref = Hosts::HostGroup.get hg.id
        ref.name.should == grp[:name]

        check_entity_evt(EntitySet.new(Hosts::HostGroup), hg.id, false)
      end

      it 'works with empty data' do
        ref = Hosts::HostGroup.get(hg.id).to_json
        update_host_group.run(hg.id, {})

        Hosts::HostGroup.get(hg.id).to_json.should == ref
      end
    end

    context 'errors' do
      it '#run raises on permission violation' do
        check_service_permission(:host_groups_write, 
                                 Hosts::UpdateHostGroup, :run, hg.id, {})
      end

      it 'raises on invalid host group' do
        expect {
          update_host_group.run(42000, {})
        }.to raise_error Exceptions::NotFound
      end
    end
  end

end

