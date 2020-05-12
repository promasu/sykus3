require 'spec_helper'

require 'services/calendar/find_resource'

module Sykus

  describe Calendar::FindResource do
    let (:identity) { IdentityTestGod.new } 
    let (:find_resource) { Calendar::FindResource.new identity }

    let! (:res) { Factory Calendar::Resource, name: 'res1', active: true }
    let! (:res2) { Factory Calendar::Resource, name: 'res2', active: false }

    context 'permission violations' do
      it 'raises on #all' do
        check_service_permission(:cal_resource_read,
                                 Calendar::FindResource, :all)
      end

      it 'raises on #by_id' do
        check_service_permission(:cal_resource_read,
                                 Calendar::FindResource, :by_id, res.id)
      end
    end

    context 'returns all Resources' do
      subject { find_resource.all }

      it { should be_a Array }

      it 'returns correct number of Resources' do 
        subject.count.should == 2
      end

      it 'returns correct Resource data' do
        subject.should =~ [ res, res2 ].map do 
          |res| find_resource.by_id res.id 
        end
      end
    end

    context 'finds Resource by id' do
      it 'finds correct Resource with all attributes' do
        ref = find_resource.by_id(res.id)

        ref[:id].should == res.id
        ref[:name].should == res.name
        ref[:active].should == res.active
      end

      it 'raises on invalid Resource' do
        expect {
          find_resource.by_id(42000)
        }.to raise_error Exceptions::NotFound
      end
    end

  end

end

