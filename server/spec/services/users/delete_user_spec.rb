require 'spec_helper'

require 'services/users/delete_user'
require 'jobs/users/update_samba_job'
require 'jobs/users/create_nss_db_job'
require 'jobs/users/update_homedir_job'
require 'jobs/users/update_radius_users_job'

module Sykus

  describe Users::DeleteUser do
    let (:identity) { IdentityTestGod.new } 
    let (:delete_user) { Users::DeleteUser.new identity }

    let (:user) { Factory Users::User }
    let (:uid) { user.id }

    context 'input parameters' do
      it 'works with user id' do
        username = user.username
        delete_user.run uid

        Users::User.get(uid).should be_nil
        check_entity_evt(EntitySet.new(Users::User), uid, true)

        Resque.dequeue(Users::UpdateSambaJob, username).should == 1
        Resque.dequeue(Users::UpdateHomedirJob, uid).should == 1
        Resque.dequeue(Users::CreateNSSDBJob).should == 1
        Resque.dequeue(Users::UpdateRADIUSUsersJob).should == 1
      end
    end

    context 'with user present in user group and owner of another group' do
      before :each do 
        Factory Users::UserGroup, owner: user 
        Factory Users::UserGroup, users: [ user ]
      end

      it 'works' do
        delete_user.run uid

        Users::User.get(uid).should be_nil
        Users::UserGroup.all.count.should == 1
      end
    end

    context 'with user sessions' do
      before :each do 
        Factory Users::Session, user: user 
      end

      it 'works' do
        delete_user.run uid

        Users::User.get(uid).should be_nil
        Users::Session.all.count.should == 0
      end
    end

    context 'with calendar events' do
      before :each do 
        Factory Calendar::Event, user: user 
      end

      it 'works' do
        delete_user.run uid

        Users::User.get(uid).should be_nil
      end
    end

    context 'errors' do
      it 'raises on permission violation' do
        check_service_permission(:users_write, Users::DeleteUser, :run, 1)
      end

      it 'raises on admin permission violation' do
        admin_id = Factory(Users::User, admin_group: :junior).id

        check_service_permission(:users_write_admin, 
                                 Users::DeleteUser, :run, admin_id)
      end

      context 'with own user identity' do
        let (:user) { Factory Users::User, admin_group: :super }

        it 'raises on self deletion' do
          identity.user_id = user.id

          expect {
            delete_user.run user.id
          }.to raise_error Exceptions::Input
        end
      end

      it 'raises on invalid id' do
        expect {
          delete_user.run 4200
        }.to raise_error Exceptions::NotFound
      end
    end
  end

end

