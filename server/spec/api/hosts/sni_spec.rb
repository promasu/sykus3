require 'spec_helper'

require 'services/users/create_session'
require 'services/hosts/find_host'
require 'services/hosts/create_host'

require 'api/main'

module Sykus

  describe 'Hosts::Host SNI API' do
    def app; Sykus::Api::App; end

    let (:identity) { IdentityTestGod.new } 

    let (:password) { 'badwolf' }
    let (:password_hash) { Digest::SHA256.hexdigest password }
    let (:password_salted) { 
      Digest::SHA256.hexdigest('SYKUSSALT' + password_hash) 
    }
    let (:user) {
      Factory Users::User, username: 'test', password_sha256: password_hash,
      admin_group: :super
    }
    let (:user_data) {{
      username: user.username,
      password: password_salted,
    }}

    let (:host_group) { Factory Hosts::HostGroup }
    let (:host_data) {{
      name: 'host01',
      host_group: host_group.name,
      mac: '00:1c:de:ad:be:ef',
    }}

    let (:confirm_host) { 
      Factory Hosts::Host, ready: false 
    }
    let (:host_confirm_data) {{
      mac: confirm_host.mac,
      cpu_speed: 120,
      ram_mb: 512,
    }}

    let (:session_id) {
      Users::CreateSession.new(IdentityAnonymous.new).run({ 
      username: user.username,
      password: password, 
    })[:id]
    }

    context 'GET /sni/login' do
      it 'creates a session' do
        get '/sni/login', user_data

        last_response.should be_ok
        session = Users::Session.get(last_response.body)
        session.should_not be_nil
      end

      it 'fails on invalid login' do
        user_data[:password] = 'bigmama'
        get '/sni/login', user_data

        last_response.should be_ok
        last_response.body.should == 'err:notfound'
      end
    end

    context 'GET /sni/add' do
      it 'adds a host' do
        get '/sni/add', host_data.merge({ session: session_id })

        last_response.should be_ok
        last_response.body.should == 'ok'
        Hosts::Host.first(mac: host_data[:mac]).should_not be_nil
      end

      it 'fails on invalid session' do
        get '/sni/add', host_data.merge({ session: 'bigbadmama' })

        last_response.should be_ok
        last_response.body.should == 'err:invalidsession'
      end

      it 'fails on invalid host data' do
        host_data[:mac] = 'deadbeef'
        get '/sni/add', host_data.merge({ session: session_id })

        last_response.should be_ok
        last_response.body.should == 'err:input'
      end
    end

    context 'GET /sni/groups' do
      it 'returns a list of host groups' do
        3.times { Factory Hosts::HostGroup }
        get '/sni/groups', { session: session_id }

        last_response.should be_ok
        last_response.body.strip.should == 
          Hosts::HostGroup.all.map { |hg| hg.name }.join(', ')
      end

      it 'fails on invalid session' do
        get '/sni/groups', host_data.merge({ session: 'bigbadmama' })

        last_response.should be_ok
        last_response.body.should == 'err:invalidsession'
      end
    end

    context 'GET /sni/confirm' do
      before :each do
        # fake remote IP
        current_session.header 'X-Forwarded-For', confirm_host.ip.to_s
      end

      it 'confirms a host' do
        get '/sni/confirm', host_confirm_data

        last_response.should be_ok
        last_response.body.should == 'ok'
        Hosts::Host.get(confirm_host.id).ready.should be_true
      end

      it 'fails on invalid host mac' do
        host_confirm_data[:mac] = 'bla'
        get '/sni/confirm', host_confirm_data

        last_response.should be_ok
        last_response.body.should == 'err:input'
      end 
    end

  end
end

