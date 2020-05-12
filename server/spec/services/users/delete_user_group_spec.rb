require 'spec_helper'

require 'services/users/delete_user_group'
require 'jobs/users/update_group_shares_job'
require 'jobs/users/delete_group_share_job'
require 'jobs/users/create_nss_db_job'

module Sykus

  describe Users::DeleteUserGroup do
    let (:identity) { IdentityTestGod.new } 
    let (:delete_user_group) { Users::DeleteUserGroup.new identity }

    let (:owner) { Factory Users::User }
    let (:ug) { Factory Users::UserGroup, owner: owner }

    context 'input parameters' do
      it 'works with user id' do
        delete_user_group.run ug.id

        Users::UserGroup.get(ug.id).should be_nil
        check_entity_evt(EntitySet.new(Users::UserGroup), ug.id, true)
      end
    end

    context 'with group members' do
      before :each do
        ug.users = [ Factory.create(Users::User) ]
        ug.save
      end

      it 'works' do
        delete_user_group.run ug.id

        Users::UserGroup.get(ug.id).should be_nil
        check_entity_evt(EntitySet.new(Users::UserGroup), ug.id, true)
        Resque.dequeue(Users::UpdateGroupSharesJob).should == 1
        Resque.dequeue(Users::DeleteGroupShareJob, ug.id).should == 1
        Resque.dequeue(Users::CreateNSSDBJob).should == 1
      end
    end

    context 'with group calendar events' do
      let! (:event) { Factory Calendar::Event, type: :group, user_group: ug }

      it 'works' do
        delete_user_group.run ug.id
        Users::UserGroup.get(ug.id).should be_nil
      end
    end

    context 'errors' do
      it 'raises on permission violation' do
        check_service_permission(:user_groups_write, 
                                 Users::DeleteUserGroup, :run, ug.id)
      end

      context 'with owner identity' do
        before :each do 
          identity.user_id = owner.id 
        end

        it 'raises if on permission violation' do
          identity.permission_table.set(:user_groups_write_own, false)

          expect {
            delete_user_group.run ug.id
          }.to raise_error Exceptions::Permission
        end

        it 'raises if user group does not belong to identity' do
          ug.owner = Factory Users::User
          ug.save
          identity.permission_table.set(:user_groups_write, false)

          expect {
            delete_user_group.run ug.id
          }.to raise_error Exceptions::Permission
        end
      end

      it 'raises on invalid id' do
        expect {
          delete_user_group.run 4200
        }.to raise_error Exceptions::NotFound
      end
    end
  end

end

