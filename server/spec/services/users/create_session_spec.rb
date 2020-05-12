require 'spec_helper'

require 'services/users/create_session'
require 'jobs/webfilter/update_nonstudents_list_job'

module Sykus

  describe Users::CreateSession do
    let (:create_session) {
      Users::CreateSession.new IdentityTestGod.new
    }

    let (:expired) { false }
    let (:password) { 'bigbadmama' }
    let (:password_sha) { Digest::SHA256.hexdigest password }
    let (:user) { 
      Factory Users::User, password_expired: expired, 
      password_sha256: password_sha 
    }

    let (:host_login) { false }

    let (:data) {{
      username: user.username, 
      password: password, 
      ip: ip,
      host_login: host_login,
    }}

    let (:salted_hash_password) { false }
    let (:ip) { nil }

    subject { create_session.run data, salted_hash_password, ip }

    def check_log(ip, login_type = :login)
      logs = Logs::SessionLog.all
      logs.count.should == 1
      log = logs.first

      log.ip.should == ip.to_s if ip
      log.username.should == data[:username]
      log.type.should == login_type
    end

    it 'creates a session' do
      res = subject
      res[:password_expired].should be_nil

      ref = Users::Session.get res[:id]

      ref.id.should == subject[:id]
      ref.user.should == user

      check_log nil
      Resque.dequeue(Webfilter::UpdateNonStudentsListJob).should == 1
    end

    context 'with host ip address' do
      let (:ip) { Factory(Hosts::Host).ip }
      let (:host_login) { true }

      it 'sets host correctly' do
        Users::Session.get(subject[:id]).host.should == 
          Hosts::Host.first(ip: ip)
        Users::Session.get(subject[:id]).ip.should == ip
      end

      it 'destroys sessions from other hosts' do
        host2 = Factory Hosts::Host
        Factory Users::Session, user: user, host: host2
        Factory Users::Session, user: user

        Users::Session.get(subject[:id]).host.should == 
          Hosts::Host.first(ip: ip)

        Users::Session.first(user: user, host: host2).should be_nil
        Users::Session.first(user: user, host: nil).should_not be_nil

        check_log ip, :host_login
      end
    end

    context 'with host ip address but no host_login flag' do
      let (:ip) { Factory(Hosts::Host).ip }

      it 'sets host to nil'  do
        Users::Session.get(subject[:id]).ip.should == ip
        Users::Session.get(subject[:id]).host.should be_nil
        check_log ip, :login
      end
    end

    context 'with external/dhcp  ip address' do
      let (:ip) { IPAddr.new('10.42.200.1') }

      it 'sets host to nil'  do
        Users::Session.get(subject[:id]).ip.should == ip
        Users::Session.get(subject[:id]).host.should be_nil
        check_log ip, :login
      end
    end

    context 'with salted hash password' do
      let (:salted_hash_password) { true }

      it 'creates a session' do
        data[:password] = Digest::SHA256.hexdigest('SYKUSSALT' + password_sha)

        ref = Users::Session.get subject[:id]

        ref.id.should == subject[:id]
        ref.user.should == user
      end
    end

    context 'with expired password' do
      let (:expired) { true }
      it 'returns password_expired' do
        res = subject
        res.should == { password_expired: true }
      end
    end

    context 'errors' do
      it 'raises on invalid login data' do
        data[:password] = 'badwolf'

        expect { subject }.to raise_error Exceptions::NotFound
      end    

      context 'with salted password hash' do
        let (:salted_hash_password) { true }

        it 'raises on invalid login data with salted password hash' do
          expect { subject }.to raise_error Exceptions::NotFound
        end
      end
    end
  end

end

