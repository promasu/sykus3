require 'spec_helper'

require 'services/calendar/delete_event'

module Sykus

  describe Calendar::DeleteEvent do
    let (:identity) { IdentityTestGod.new } 
    let (:delete_event) { Calendar::DeleteEvent.new identity }

    let (:user) { Factory Users::User }

    let (:event) { Factory Calendar::Event, type: :global }
    let (:id) { event.id }

    before :each do
      identity.user_id = user.id
    end

    context 'input parameters' do
      it 'works with event id' do
        cal_id = event.cal_id
        delete_event.run id

        Calendar::Event.get(id).should be_nil
        check_entity_evt(EntitySet.new(Calendar::Event, cal_id), id, true)
      end
    end

    context 'with write permission / own events' do
      before :each do 
        event.user = user
        event.save

        identity.permission_table.set(:calendar_global_admin, false)
      end

      it 'works' do
        delete_event.run id

        Calendar::Event.get(id).should be_nil
      end
    end

    context 'errors' do
      context 'without write permission / own events' do
        before :each do 
          event.user = user
          event.save

          identity.permission_table.set(:calendar_global_admin, false)
          identity.permission_table.set(:calendar_global_write, false)
        end

        it 'works' do
          expect {
            delete_event.run id
          }.to raise_error Exceptions::Permission
        end
      end

      context 'with write permission / non-owned events' do
        before :each do 
          identity.permission_table.set(:calendar_global_admin, false)
        end

        it 'raises' do
          expect {
            delete_event.run id
          }.to raise_error Exceptions::Permission
        end
      end

      it 'raises on invalid id' do
        expect {
          delete_event.run 4200
        }.to raise_error Exceptions::NotFound
      end
    end
  end

end

