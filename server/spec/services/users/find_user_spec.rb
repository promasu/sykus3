require 'spec_helper'

require 'services/users/find_user'

module Sykus

  describe Users::FindUser do
    let (:name) { Users::FullUserName.new('John', 'Doe') }
    let (:uc) { Factory Users::UserClass }
    let (:user) { 
      Factory Users::User, password_initial: '123', position_group: :student,
      user_class: uc
    }
    let (:identity) { IdentityTestGod.new }
    let (:find_user) { Users::FindUser.new identity }

    def check_user(result, ref)
      result[:id].should == ref.id
      result[:username].should == ref.username
      result[:first_name].should == ref.full_name.first_name
      result[:last_name].should == ref.full_name.last_name
      result[:birthdate].should == ref.birthdate
      result[:password_initial].should == ref.password_initial
      result[:position_group].should == ref.position_group.to_s
      result[:admin_group].should == ref.admin_group.to_s
      result[:quota_used_mb].should == ref.quota_used_mb
      result[:quota_total_mb].should == Users::GetUserMaxQuota.get(user)
      result[:user_class].should == ref.user_class.id
    end

    context 'permission violations' do
      it 'raises on #all' do
        check_service_permission(:users_read, Users::FindUser, :all)
      end

      it 'raises on #by_id' do
        check_service_permission(:users_read, Users::FindUser, :by_id, 42)
      end

      it 'raises on #by_name' do
        check_service_permission(:users_read, Users::FindUser, :by_name, 'a')
      end
    end

    context 'returns all users' do
      subject { find_user.all }

      before :each do
        3.times { Factory Users::User, full_name: name }
      end

      it { should be_a Array }

      it 'returns correct number of users' do 
        subject.count.should == 3
      end

      it 'returns correct user data' do
        subject.each do |user|
          user[:first_name].should == name.first_name
        end
      end
    end

    context 'without users_read_initial_password permission' do
      before :each do
        user
        identity.permission_table.set(:users_read_password_initial, false)
      end

      it 'should not return password_initial' do
        find_user.all.first[:password_initial].should be_nil
      end
    end

    context 'finds user by id' do
      it 'finds correct user with all attributes' do
        res = find_user.by_id(user.id)
        check_user res, user
      end

      it 'finds a user with no user class' do
        u = Factory Users::User, user_class: nil

        res = find_user.by_id(u.id)
        res[:user_class].should be_nil
      end

      it 'raises on invalid user' do
        expect {
          find_user.by_id(42000)
        }.to raise_error Exceptions::NotFound
      end
    end

    context 'finds user by name' do
      it 'finds correct user' do
        res = find_user.by_name(user.username)
        check_user res, user
      end

      it 'raises on invalid user' do
        expect {
          find_user.by_name('johann_pupenmeier')
        }.to raise_error Exceptions::NotFound
      end
    end
  end

end

