require 'spec_helper'

require 'services/calendar/delete_resource'

module Sykus

  describe Calendar::DeleteResource do
    let (:identity) { IdentityTestGod.new } 
    let (:delete_resource) { Calendar::DeleteResource.new identity }

    let! (:res) { Factory Calendar::Resource }

    it 'deletes a resource' do
      delete_resource.run res.id

      Calendar::Resource.get(res.id).should be_nil
      check_entity_evt(EntitySet.new(Calendar::Resource), res.id, true)
    end

    context 'with class calendar events' do
      let! (:event) { Factory Calendar::Event, type: :resource, resource: res }

      it 'works' do
        delete_resource.run res.id
        Calendar::Resource.get(res.id).should be_nil
      end
    end

    context 'errors' do
      it 'raises on permission violation' do
        check_service_permission(:cal_resource_write,
                                 Calendar::DeleteResource, :run, res.id)
      end

      it 'raises on invalid id' do
        expect {
          delete_resource.run 4200
        }.to raise_error Exceptions::NotFound
      end
    end
  end

end

