require 'spec_helper'

require 'services/calendar/create_event'

module Sykus

  describe Calendar::CreateEvent do
    let (:identity) { IdentityTestGod.new } 
    let (:create_event) { Calendar::CreateEvent.new identity }

    let (:user) { Factory Users::User }

    let (:res) { Factory Calendar::Resource }
    let (:uc) { Factory Users::UserClass }
    let (:ug) { Factory Users::UserGroup }

    let (:event1) {{
      start: 123,
      :end => 234,
      all_day: true,
      cal_id: 'global',
      title: 'Event',
      location: 'There',
    }}

    before :each do 
      identity.user_id = user.id
    end

    subject { create_event.run event1 }

    it 'works with all required parameters' do
      result = subject 

      id = result[:id]
      id.should be_a Integer

      event = Calendar::Event.get id
      event.start.should == Time.at(123)
      event.end.should == Time.at(234)
      event.all_day.should == true
      event.cal_id.should == 'global'
      event.title.should == 'Event'
      event.location.should == 'There'
      event.user_class.should be_nil
      event.user_group.should be_nil

      check_entity_evt(EntitySet.new(Calendar::Event, event.cal_id),
                       id, false)
    end

    # do only superficial checks, rely on correct use of
    # Calendar::CalendarPermission (this is tested in its own spec)
    context 'permissions' do
      it 'works with admin permission' do
        identity.only_permission(:calendar_global_admin)
        subject
      end

      it 'works with write permission' do
        identity.only_permission(:calendar_global_write)
        subject
      end

      it 'raises without proper permissions' do
        identity.only_permission(nil)
        expect { subject }.to raise_error Exceptions::Permission
      end
    end

    it 'creates valid group event' do
      ug.users = [ user ]
      ug.save

      event1[:cal_id] = "group:#{ug.id}"
        result = subject

      Calendar::Event.get(result[:id]).user_group.should == ug
    end

    it 'creates valid class event' do
      event1[:cal_id] = "class:#{uc.id}"
        result = subject

      Calendar::Event.get(result[:id]).user_class.should == uc
    end

    it 'creates valid resource event' do
      event1[:cal_id] = "resource:#{res.id}"
        result = subject

      Calendar::Event.get(result[:id]).resource.should == res
    end

    context 'errors' do
      it 'fails on invalid cal id event' do
        event1[:cal_id] = 'test'
        expect { subject }.to raise_error Exceptions::Input
      end

      it 'fails on invalid cal id (group) event' do
        event1[:cal_id] = 'group:42'
        expect { subject }.to raise_error Exceptions::Input
      end

      it 'fails on invalid cal id (class) event' do
        event1[:cal_id] = 'class:42'
        expect { subject }.to raise_error Exceptions::Input
      end

    end
    end

  end

