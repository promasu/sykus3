require 'spec_helper'

require 'services/calendar/create_resource'

module Sykus

  describe Calendar::CreateResource do
    let (:identity) { IdentityTestGod.new } 
    let (:create_resource) { Calendar::CreateResource.new identity }

    it 'creates a Resource' do
      res = create_resource.run name: 'res1' 

      res[:id].should be_a Integer

      ref = Calendar::Resource.get(res[:id])
      ref.name.should == 'res1'
      ref.active.should == true
      check_entity_evt(EntitySet.new(Calendar::Resource), res[:id], false)
    end

    context 'errors' do
      it 'fails on duplicate class' do
        create_resource.run name: 'res1' 

        expect {
          create_resource.run name: 'res1'
        }.to raise_error Exceptions::Input
      end

      it '#run raises on permission violation' do
        check_service_permission(:cal_resource_write, Calendar::CreateResource, 
                                 :run, { name: 'res1' })
      end
    end
  end

end

