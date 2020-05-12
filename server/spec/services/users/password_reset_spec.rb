require 'spec_helper'

require 'services/users/password_reset'
require 'jobs/users/update_samba_job'
require 'jobs/users/update_radius_users_job'

module Sykus

  describe Users::PasswordReset do
    let (:identity) { IdentityTestGod.new }
    let (:password_reset) { Users::PasswordReset.new identity }

    let! (:person) { Factory Users::User, position_group: :person }

    let (:uc) { Factory Users::UserClass }
    let! (:student) { 
      Factory Users::User, position_group: :student, user_class: uc 
    }
    let! (:teacher) { Factory Users::User, position_group: :teacher }
    let! (:admin) { 
      Factory Users::User, position_group: :student, user_class: uc,
      admin_group: :junior 
    }

    subject { password_reset.run person.id }

    context 'password reset' do
      it 'creates new passwords' do
        password = subject[:password]
        password.should be_a String

        user = Users::User.get(person.id)

        user.password_expired.should == true
        user.password_sha256.should == Digest::SHA256.hexdigest(password)

        # make sure this is not a valid password
        user.password_nt.should_not == NTHash.get(password)

        Resque.dequeue(Users::UpdateSambaJob, user.username).should == 1
        Resque.dequeue(Users::UpdateRADIUSUsersJob).should == 1
      end
    end

    def check_initial_password(user, flag)
      password = password_reset.run(user.id)[:password]
      Users::User.get(user.id).password_initial.should == 
        (flag ? password : nil)
    end

    context 'initial password' do
      it 'is correct for student' do
        check_initial_password student, true 
      end
      it 'is correct for teacher' do
        check_initial_password teacher, true 
      end
      it 'is correct for person' do
        check_initial_password person, false 
      end
      it 'is correct for admin' do
        check_initial_password admin, false 
      end
    end

    context 'errors' do
      it 'raises on permission violation (non-student)' do
        check_service_permission(:users_write, 
                                 Users::PasswordReset, :run, person.id)
      end

      it 'raises on permission violation (student)' do
        check_service_permission(:teacher_studentpwd, 
                                 Users::PasswordReset, :run, student.id)
      end

      it 'raises on admin permission violation' do
        check_service_permission(:users_write_admin, 
                                 Users::PasswordReset, :run, admin.id)
      end

      it 'raises when using own identity' do
        identity.user_id = person.id

        expect {
          password_reset.run(person.id)
        }.to raise_error Exceptions::Input
      end

      it 'raises on invalid id' do
        expect {
          password_reset.run(4200)
        }.to raise_error Exceptions::NotFound
      end
      end
  end

end

