require 'spec_helper'

require 'services/users/change_password'
require 'jobs/users/update_samba_job'
require 'jobs/users/update_radius_users_job'

module Sykus

  describe Users::ChangePassword do
    let (:change_password) { 
      Users::ChangePassword.new IdentityAnonymous.new 
    }

    let (:password) { 'badmama' }
    let (:password_sha256) { Digest::SHA256.hexdigest password }
    let (:expired) { false }
    let (:user) { 
      Factory Users::User, password_sha256: password_sha256,
      password_expired: expired, password_initial: '123'
    }
    let (:uid) { user.id }
    let (:ip) { Factory(Hosts::Host).ip }

    let (:new_password) { 'badwolf1234' }
    let (:data) {{
      username: user.username, 
      old_password: password,
      new_password: new_password,
    }}

    context 'password reset' do
      it 'creates new passwords' do
        change_password.run(data, nil)

        user = Users::User.get(uid)

        user.password_expired.should == false
        user.password_initial.should be_nil
        user.password_sha256.should == Digest::SHA256.hexdigest(new_password)
        user.password_nt.should == NTHash.get(new_password)

        Resque.dequeue(Users::UpdateSambaJob, user.username).should == 1
        Resque.dequeue(Users::UpdateRADIUSUsersJob).should == 1
      end
    end

    context 'invalid ip and expired' do
      let (:ip) { IPAddr.new '10.21.2.1' }
      let (:expired) { true }

      it 'raises' do
        expect {
          change_password.run(data, ip)
        }.to raise_error
      end
    end

    context 'short password' do
      let (:new_password) { 'abc' }
      it 'raises' do
        expect {
          change_password.run(data, ip)
        }.to raise_error
      end
    end

    context 'errors' do
      it 'raises on invalid data' do
        data[:username] = 'x'
        expect {
          change_password.run(data, ip)
        }.to raise_error Exceptions::NotFound
      end
    end
  end

end

