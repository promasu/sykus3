require 'spec_helper'

require 'services/calendar/update_resource'

module Sykus

  describe Calendar::UpdateResource do
    let (:identity) { IdentityTestGod.new } 
    let (:update_resource) { Calendar::UpdateResource.new identity } 

    let (:res) { Factory Calendar::Resource, name: 'res1' }

    let (:resnew) {{
      name: 'res2',
      active: false,
    }}

    context 'input parameters' do
      it 'works with all attributes' do
        update_resource.run(res.id, resnew)

        ref = Calendar::Resource.get res.id
        ref.name.should == 'res2'
        ref.active.should be_false

        check_entity_evt(EntitySet.new(Calendar::Resource), res.id, false)
      end

      it 'works with empty data' do
        ref = Calendar::Resource.get(res.id).to_json
        update_resource.run(res.id, {})

        Calendar::Resource.get(res.id).to_json.should == ref
      end
    end

    context 'errors' do
      it '#run raises on permission violation' do
        check_service_permission(:cal_resource_write, Calendar::UpdateResource, 
                                 :run, res.id, { name: 'res2' })
      end
    end
  end

end

