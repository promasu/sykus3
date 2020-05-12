require 'spec_helper'

require 'services/users/update_user'
require 'jobs/users/update_samba_job'
require 'jobs/users/create_nss_db_job'
require 'jobs/users/update_homedir_job'
require 'jobs/users/update_radius_users_job'

module Sykus

  describe Users::UpdateUser do
    let (:identity) { IdentityTestGod.new } 
    let (:update_user) { Users::UpdateUser.new identity } 

    let (:user) { Factory Users::User }
    let (:uid) { user.id }
    let (:new_class) { Factory Users::UserClass }

    context 'input parameters' do
      it 'works with all attributes' do
        old_username = user.username
        update_user.run(uid, {
          username: 'doejohn',
          first_name: 'John',
          last_name: 'Doe',
          birthdate: '01.02.1950',
          position_group: :student,
          admin_group: :junior,
          user_class: new_class.id,
        })

        ref = Users::User.get uid
        ref.username.should == 'doejohn'
        ref.full_name.should == Users::FullUserName.new('John', 'Doe')
        ref.birthdate.should == '01.02.1950'
        ref.position_group.should == :student
        ref.admin_group.should == :junior
        ref.user_class.should == new_class

        check_entity_evt(EntitySet.new(Users::User), uid, false)

        Resque.dequeue(Users::UpdateSambaJob, old_username).should == 1
        Resque.dequeue(Users::UpdateSambaJob, ref.username).should == 1
        Resque.dequeue(Users::UpdateHomedirJob, user.id).should == 1
        Resque.dequeue(Users::CreateNSSDBJob).should == 1
        Resque.dequeue(Users::UpdateRADIUSUsersJob).should == 1
      end

      it 'works with empty data' do
        ref = Users::User.get(uid).to_json
        update_user.run uid, {}
        Users::User.get(uid).to_json.should == ref
      end
    end

    context 'errors' do
      it 'fails on system user' do
        expect { 
          update_user.run(uid, { username: 'root' })
        }.to raise_error Exceptions::Input
      end

      it 'raises on permission violations' do
        check_service_permission(:users_write, 
                                 Users::UpdateUser, :run, 4200, {})
      end

      it 'raises on admin permission violation (1)' do
        data = { admin_group: :junior }

        check_service_permission(:users_write_admin, 
                                 Users::UpdateUser, :run, uid, data)
      end

      it 'raises on admin permission violation (2)' do
        uid = Factory(Users::User, admin_group: :junior).id
        data = { admin_group: :none }

        check_service_permission(:users_write_admin, 
                                 Users::UpdateUser, :run, uid, data)
      end 

      context 'with own user identity' do
        let (:user) { Factory Users::User, admin_group: :super }

        it 'raises on admin group change' do
          identity.user_id = user.id
          data = { admin_group: :junior }

          expect {
            update_user.run(user.id, data)
          }.to raise_error Exceptions::Input
        end
      end

      it 'raises on invalid id' do
        expect {
          update_user.run(4200, {})
        }.to raise_error Exceptions::NotFound
      end
    end
  end

end

