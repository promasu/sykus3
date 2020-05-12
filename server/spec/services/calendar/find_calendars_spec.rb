require 'spec_helper'

require 'services/calendar/find_calendars'

module Sykus

  describe Calendar::FindCalendars do
    let (:identity) { IdentityTestGod.new }
    let (:find_calendars) { Calendar::FindCalendars.new identity }

    let! (:user) { Factory Users::User, id: 1 }
    let! (:ug) { Factory Users::UserGroup, id: 1 }
    let! (:ug2) { Factory Users::UserGroup, id: 2 }
    let! (:uc) { Factory Users::UserClass, id: 1, grade: 7 }
    let! (:uc2) { Factory Users::UserClass, id: 2, grade: 8 }
    let! (:res) { Factory Calendar::Resource, id: 1 }
    let! (:res2) { Factory Calendar::Resource, id: 2 }

    before :each do
      identity.user_id = user.id
    end

    subject { find_calendars.all }

    context 'with admin permissions' do
      it 'returns all calendar ids with admin perm (except groups)' do
        subject.should == {
          'global' => :admin,
          'teacher' => :admin,
          'private:1' => :admin,

          'class:1' => :admin,
          'class:2' => :admin,
          'grade:7' => :admin,
          'grade:8' => :admin,
          'resource:1' => :admin,
          'resource:2' => :admin,
        }
      end
    end

    context 'with no permissions' do
      before :each do
        identity.only_permission(nil)
      end

      it 'returns only global and own calendar' do
        subject.should == {
          'global' => :read,
          'private:1' => :admin,
        }
      end
    end

    context 'with group membership' do
      before :each do
        identity.only_permission(nil)
        ug.users = [ user ]
        ug.save
      end

      it 'returns only global and own calendar' do
        subject.should == {
          'global' => :read,
          'private:1' => :admin,

          'group:1' => :write,
        }
      end
    end

    context 'with class membership' do
      before :each do
        identity.only_permission(nil)
        user.position_group = :student
        user.user_class = uc
        user.save
      end

      it 'returns only global and own calendar' do
        subject.should == {
          'global' => :read,
          'private:1' => :admin,

          'class:1' => :read,
          'grade:7' => :read,
        }
      end
    end

    context 'simplified permission tests' do
      it 'for class_read' do
        identity.only_permission(:calendar_class_read)
        subject['class:1'].should_not be_nil
      end

      it 'for class_write' do
        identity.only_permission(:calendar_class_write)
        subject['class:1'].should_not be_nil
      end

      it 'for class_admin' do
        identity.only_permission(:calendar_class_admin)
        subject['class:1'].should_not be_nil
      end

      it 'for resource_read ' do
        identity.only_permission(:calendar_resource_read)
        subject['resource:1'].should_not be_nil
      end

      it 'for resource_write' do
        identity.only_permission(:calendar_resource_write)
        subject['resource:1'].should_not be_nil
      end

      it 'for resource_admin' do
        identity.only_permission(:calendar_resource_admin)
        subject['resource:1'].should_not be_nil
      end
    end

  end

end

