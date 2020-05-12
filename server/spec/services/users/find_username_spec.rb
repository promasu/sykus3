require 'spec_helper'

require 'services/users/find_username'

module Sykus

  describe Users::FindUsername do
    let (:find_username) { 
      Users::FindUsername.new IdentityTestGod.new 
    }

    let (:johndoe) {{
      username: 'doejohn',
      first_name: 'John',
      last_name: 'Doe',
      birthdate: '11.05.2011',
    }}

    let (:data) {{ 
      first_name: 'John',
      last_name: 'Doe'
    }}

    subject { find_username.run data }

    context 'finding username' do
      it 'gives the correct username' do
        subject[:username].should == 'doejohn'
      end

      it 'gives the correct username with user present and ref id' do
        user = Factory Users::User, johndoe
        data[:ref_id] = user.id

        subject[:username].should == 'doejohn'
      end

      it 'gives the correct username if one johndoe is already present' do
        Factory Users::User, johndoe

        subject[:username].should == 'doejohn1'
      end
    end

    context 'errors' do
      it '#username raises on permission violation' do
        check_service_permission(:users_read, 
                                 Users::FindUsername, :run, {})
      end

      it 'returns false on invalid input' do
        data[:first_name] = ''

        subject[:username].should == false
      end
    end
  end

end

