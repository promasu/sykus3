require 'spec_helper'

require 'services/users/create_user'
require 'jobs/users/update_samba_job'
require 'jobs/users/create_nss_db_job'
require 'jobs/users/update_homedir_job'
require 'jobs/users/update_radius_users_job'

module Sykus

  describe Users::CreateUser do
    let (:create_user) { Users::CreateUser.new IdentityTestGod.new }

    let (:user_class) { Factory Users::UserClass }
    let (:johndoe) {{
      username: 'doejohn',
      first_name: 'John',
      last_name: 'Doe',
      birthdate: '11.05.2011',
      position_group: 'person',
      admin_group: 'none',
      user_class: user_class.id
    }}

    subject { create_user.run johndoe }

    it 'works with all required parameters' do
      result = subject 

      id = result[:id]
      id.should be_a Integer
      result[:password].should be_a String

      user = Users::User.get id
      user.username.should == 'doejohn'
      user.full_name.should == Users::FullUserName.new('John', 'Doe')
      user.position_group.should == :person
      user.admin_group.should == :none
      user.user_class.should == nil

      check_entity_evt(EntitySet.new(Users::User), id, false)

      Resque.dequeue(Users::UpdateSambaJob, user.username).should == 1
      Resque.dequeue(Users::UpdateHomedirJob, user.id).should == 1
      Resque.dequeue(Users::CreateNSSDBJob).should == 1
      Resque.dequeue(Users::UpdateRADIUSUsersJob).should == 1
    end

    it 'should accept user class if student' do
      johndoe[:position_group] = 'student'
      result = subject

      Users::User.get(result[:id]).user_class.should == user_class
    end

    it 'work without userclass for non-students' do
      johndoe[:user_class] = nil

      subject
    end

    context 'errors' do
      it 'fails on system user' do
        johndoe[:username] = 'root'

        expect { subject }.to raise_error Exceptions::Input
      end

      it '#run raises on permission violation' do
        check_service_permission(:users_write, Users::CreateUser, :run, {})
      end

      it 'requires admin-write if you create an admin' do
        [ :junior, :senior, :super ].each do |type|
          johndoe[:admin_group] = type

          check_service_permission(:users_write_admin, 
                                   Users::CreateUser, :run, johndoe)
        end
      end

      [ 
        :username, :first_name, :last_name, :birthdate,
        :position_group, :admin_group,
      ].each do |element|
        it "raises if #{element} is missing" do
          johndoe.delete element

          expect { subject }.to raise_error Exceptions::Input
        end
      end

      it 'raises on student without userclass' do
        johndoe[:position_group] = 'student'
        johndoe[:user_class] = nil

        expect { subject }.to raise_error Exceptions::Input
      end

      it 'raises on duplicate username' do
        create_user.run johndoe

        expect { subject }.to raise_error Exceptions::Input
      end
    end
  end

end

