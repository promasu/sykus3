require 'spec_helper'

module Sykus

  describe Calendar::CalendarPermission do
    let! (:user) { Factory Users::User }
    let! (:identity) { IdentityTestGod.new }

    let! (:res) { Factory Calendar::Resource }
    let! (:uc) { Factory Users::UserClass }
    let! (:ug) { Factory Users::UserGroup }

    before :each do
      identity.user_id = user.id
    end

    def get(cal_id)
      Calendar::CalendarPermission.get(identity, cal_id)
    end

    context 'with id:private' do
      it 'is correct for self' do 
        identity.only_permission(nil)
        get("private:#{user.id}").should == :admin
      end

      # even with all permissions
      it 'is correct for not self' do 
        get("private:4200").should == :none
      end
    end

    context 'with id:global' do
      it 'is correct for admin' do 
        identity.only_permission(:calendar_global_admin)
        get('global').should == :admin
      end

      it 'is correct for write' do 
        identity.only_permission(:calendar_global_write)
        get('global').should == :write
      end

      it 'is correct for nothing' do 
        identity.only_permission(nil)
        get('global').should == :read
      end
    end

    context 'with id:teacher' do
      it 'is correct for admin' do 
        identity.only_permission(:calendar_teacher_admin)
        get('teacher').should == :admin
      end

      it 'is correct for write' do 
        identity.only_permission(:calendar_teacher_write)
        get('teacher').should == :write
      end

      it 'is correct for read' do 
        identity.only_permission(:calendar_teacher_read)
        get('teacher').should == :read
      end

      it 'is correct for nothing' do 
        identity.only_permission(nil)
        get('teacher').should == :none
      end
    end

    context 'with id:group' do
      before :each do
        identity.only_permission(nil)
      end

      it 'is correct for user' do
        ug.owner = user
        ug.save

        get("group:#{ug.id}").should == :admin
      end

      it 'is correct for member' do
        ug.users = [ user ]
        ug.save

        get("group:#{ug.id}").should == :write
      end

      it 'is correct for nothing' do
        get("group:#{ug.id}").should == :none
      end
    end

    context 'with id:group and admin permissions' do
      it 'is correct for nothing' do
        get("group:#{ug.id}").should == :admin
      end
    end

    context 'with id:grade' do
      it 'is correct for admin' do
        identity.only_permission(:calendar_grade_admin)
        get("grade:7").should == :admin
      end

      it 'is correct for write' do
        identity.only_permission(:calendar_grade_write)
        get("grade:7").should == :write
      end

      it 'is correct for read' do
        identity.only_permission(:calendar_grade_read)
        get("grade:7").should == :read
      end

      it 'is correct for member' do
        identity.only_permission(nil)

        user.position_group = :student
        user.user_class = uc
        user.save
        uc.grade = 7
        uc.save

        get("grade:7").should == :read
      end

      it 'is correct for nothing' do
        identity.only_permission(nil)
        get("grade:7").should == :none
      end
    end

    context 'with id:class' do
      it 'is correct for admin' do
        identity.only_permission(:calendar_class_admin)
        get("class:#{uc.id}").should == :admin
      end

      it 'is correct for write' do
        identity.only_permission(:calendar_class_write)
        get("class:#{uc.id}").should == :write
      end

      it 'is correct for read' do
        identity.only_permission(:calendar_class_read)
        get("class:#{uc.id}").should == :read
      end

      it 'is correct for member' do
        identity.only_permission(nil)

        user.position_group = :student
        user.user_class = uc
        user.save

        get("class:#{uc.id}").should == :read
      end

      it 'is correct for nothing' do
        identity.only_permission(nil)
        get("class:#{uc.id}").should == :none
      end
    end

    context 'with id:resource' do
      it 'is correct for admin' do 
        identity.only_permission(:calendar_resource_admin)
        get("resource:#{res.id}").should == :admin
      end

      it 'is correct for write' do 
        identity.only_permission(:calendar_resource_write)
        get("resource:#{res.id}").should == :write
      end

      it 'is correct for read' do 
        identity.only_permission(:calendar_resource_read)
        get("resource:#{res.id}").should == :read
      end

      it 'is correct for nothing' do 
        identity.only_permission(nil)
        get("resource:#{res.id}").should == :none
      end
    end

    context 'with id:invalid' do
      it 'raises' do
        expect {
          get('invalid')
        }.to raise_error Exceptions::Input
      end
    end

    context 'with id:group:invalid' do
      it 'raises' do
        expect {
          get('group:4200')
        }.to raise_error Exceptions::NotFound
      end
    end

    context 'with id:class:invalid' do
      it 'raises' do
        expect {
          get('class:4200')
        }.to raise_error Exceptions::NotFound
      end
    end
  end

end

