require 'spec_helper'

require 'services/users/auth'

module Sykus

  describe Users::Auth do
    let (:auth) {
      Users::Auth.new IdentityTestGod.new
    }

    let (:expired) { false }
    let (:password) { 'bigbadmama' }
    let (:password_sha) { Digest::SHA256.hexdigest password }
    let (:user) { 
      Factory Users::User, password_expired: expired, 
      password_sha256: password_sha 
    }

    let (:data) {{
      username: user.username, 
      password: password, 
      ip: ip,
    }}

    let (:ip) { IPAddr.new '10.42.42.1' }

    subject { auth.run data, ip }

    def check_log(ip)
      logs = Logs::SessionLog.all
      logs.count.should == 1
      log = logs.first

      log.ip.should == ip.to_s
      log.username.should == data[:username]
      log.type.should == :auth
    end

    it 'creates a session' do
      res = subject

      res[:username].should == user.username
      res[:first_name].should == user.full_name.first_name
      res[:last_name].should == user.full_name.last_name
      res[:birthdate].should == user.birthdate
      res[:position_group].should == user.position_group.to_s
      res[:admin_group].should == user.admin_group.to_s

      check_log ip
    end


    context 'with expired password' do
      let (:expired) { true }
      it 'raises' do
        expect { subject }.to raise_error Exceptions::NotFound
      end
    end

    context 'errors' do
      it 'raises on invalid login data' do
        data[:password] = 'badwolf'

        expect { subject }.to raise_error Exceptions::NotFound
      end    
    end
  end

end

