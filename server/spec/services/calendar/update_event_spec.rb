require 'spec_helper'

require 'services/calendar/update_event'

module Sykus

  describe Calendar::UpdateEvent do
    let (:identity) { IdentityTestGod.new } 
    let (:update_event) { Calendar::UpdateEvent.new identity } 

    let (:user) { Factory Users::User }
    let! (:event) { Factory Calendar::Event, type: :global }
    let (:id) { event.id }

    before :each do
      identity.user_id = user.id
    end

    context 'input parameters' do
      it 'works with all attributes' do
        old_cal_id = event.cal_id

        update_event.run(id, {
          start: 123,
          :end => 234,
          all_day: true,
          cal_id: 'teacher',
          title: 'Event',
          location: 'There',
        })

        ref = Calendar::Event.get id

        ref.start.should == Time.at(123)
        ref.end.should == Time.at(234)
        ref.all_day.should == true
        ref.cal_id.should == 'teacher'
        ref.title.should == 'Event'
        ref.location.should == 'There'
        ref.user_class.should be_nil
        ref.user_group.should be_nil

        check_entity_evt(EntitySet.new(Calendar::Event, old_cal_id),
                         id, true)
        check_entity_evt(EntitySet.new(Calendar::Event, ref.cal_id), 
                         id, false)
      end

      it 'works with empty data' do
        ref = Calendar::Event.get(id).to_json
        update_event.run id, {}
        Calendar::Event.get(id).to_json.should == ref

        check_entity_evt(EntitySet.new(Calendar::Event, event.cal_id), 
                         id, false)
      end

      it 'works without admin permissions if own event' do
        identity.permission_table.set(:calendar_global_admin, false)
        event.user = user
        event.save

        update_event.run(id, {})
      end
    end

    context 'errors' do
      it 'needs admin permissions to change non-owned events' do
        identity.permission_table.set(:calendar_global_admin, false)

        expect {
          update_event.run(id, {})
        }.to raise_error Exceptions::Permission
      end

      it 'needs write or admin permissions to change own events' do
        event.user = user
        event.save

        identity.permission_table.set(:calendar_global_admin, false)
        identity.permission_table.set(:calendar_global_write, false)

        expect {
          update_event.run(id, {})
        }.to raise_error Exceptions::Permission
      end

      it 'raises on invalid id' do
        expect {
          update_event.run(4200, {})
        }.to raise_error Exceptions::NotFound
      end
    end
  end

end

