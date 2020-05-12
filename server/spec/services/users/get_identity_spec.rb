require 'spec_helper'

require 'services/users/get_identity'

module Sykus

  describe Users::GetIdentity do
    let (:user) { 
      Factory Users::User, position_group: :teacher, admin_group: :junior 
    }
    let (:session) { Factory Users::Session, user: user }
    let (:identity) { IdentityUser.new session }
    let (:get_identity) { Users::GetIdentity.new identity }

    subject { get_identity.run }

    it 'returns a valid identity user: object' do
      subject[:user][:id].should == user.id
      subject[:user][:username].should == user.username
      subject[:user][:first_name].should == user.full_name.first_name
      subject[:user][:last_name].should == user.full_name.last_name
      subject[:user][:position_group].should == user.position_group
      subject[:user][:admin_group].should == user.admin_group
    end

    it 'returns permission object' do
      subject[:permissions].should =~ Users::UserPermissions.get(user)
    end
  end

end

