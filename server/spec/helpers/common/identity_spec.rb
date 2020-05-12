require 'spec_helper'


module Sykus

  describe IdentityBase do
    it 'fails on initialization' do
      expect { IdentityBase.new }.to raise_error
    end

    shared_examples :service_base do
      it 'returns a name' do
        subject.name.should be_a String
        subject.name.length.should > 1
      end

      it 'responds to #enforce_permission' do
        subject.should respond_to :enforce_permission!
      end

      it 'responds to #permissions' do
        subject.permissions.should be_a Array
      end
    end

    describe IdentityUser do
      let (:user) { 
        Factory Users::User, position_group: :person, admin_group: :junior
      }
      let (:session) { Factory Users::Session, user: user }
      subject { IdentityUser.new session }

      it_behaves_like :service_base

      it 'creates a valid identity' do
        subject.name.should include user.id.to_s
        subject.name.should include user.username
      end

      it 'has correct permissions' do
        subject.permissions.should =~ 
        (Config::Permissions::PositionPerson +
         Config::Permissions::AdminJunior).to_a
      end
    end

    describe IdentityTestGod do
      subject { IdentityTestGod.new }

      it_behaves_like :service_base

      it 'has all permissions enabled' do
        Config::Permissions::PermissionList.each do |p|
          subject.enforce_permission! p
        end
      end


      context 'with only_permission nil' do
        before :each do
          subject.only_permission(nil)
        end

        it 'has all permissions disabled' do 
          Config::Permissions::PermissionList.each do |p|
            expect {
              subject.enforce_permission! p
            }.to raise_error Exceptions::Permission
          end
        end
      end


      context 'with only_permission' do
        let (:perm1) { Config::Permissions::PermissionList.first }

        before :each do
          subject.only_permission(perm1)
        end

        it 'has all permissions disabled except for one' do 
          Config::Permissions::PermissionList.each do |p|
            if p == perm1
              subject.enforce_permission! p
            else
              expect {
                subject.enforce_permission! p
              }.to raise_error Exceptions::Permission
            end
          end
        end
      end
    end

    describe IdentityAnonymous do
      subject { IdentityAnonymous.new }

      it_behaves_like :service_base

      it 'has all permissions disabled' do 
        Config::Permissions::PermissionList.each do |p|
          expect {
            subject.enforce_permission! p
          }.to raise_error Exceptions::Permission
        end
      end
    end
  end
end


