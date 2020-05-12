require 'spec_helper'

require 'services/hosts/find_host_group'

module Sykus

  describe Hosts::FindHostGroup do
    let (:identity) { IdentityTestGod.new } 
    let (:find_host_group) { Hosts::FindHostGroup.new identity }

    let! (:hg) { Factory Hosts::HostGroup, name: 'nicehosts' }
    let! (:hg2) { Factory Hosts::HostGroup, name: 'sweethosts' }

    context 'permission violations' do
      it 'raises on #all' do
        check_service_permission(:host_groups_read, 
                                 Hosts::FindHostGroup, :all)
      end

      it 'raises on #by_id' do
        check_service_permission(:host_groups_read, 
                                 Hosts::FindHostGroup, :by_id, 42)
      end
    end

    context 'returns all host groups' do
      subject { find_host_group.all }

      it { should be_a Array }

      it 'returns correct number of host groups' do 
        subject.count.should == 2
      end

      it 'returns correct host group data' do
        subject.should =~ [ hg, hg2 ].map do 
          |hg| find_host_group.by_id hg.id 
        end
      end
    end

    context 'finds host group by id' do
      it 'finds correct host group with all attributes' do
        res = find_host_group.by_id(hg.id)

        res[:id].should == hg.id
        res[:name].should == hg.name
      end

      it 'raises on invalid host group' do
        expect {
          find_host_group.by_id(42000)
        }.to raise_error Exceptions::NotFound
      end
    end

  end

end

