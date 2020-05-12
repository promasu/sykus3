module Sykus

  module SpecHelpers
    def json_response
      JSON.parse last_response.body, { symbolize_names: true }
    end

    def check_service_permission(permission, service_class, method, *args)
      identity = IdentityTestGod.new
      identity.permission_table.set(permission, false)

      service = service_class.new identity

      expect {
        service.send(method, *args)
      }.to raise_error { |error|
        error.should be_a Exceptions::Permission
        error.permission.should == permission
      }
    end

    def check_entity_evt(entity_set, id, deleted)
      res = EntityEventStore.get_events_since(entity_set, Time.now.to_i - 1)
      res.select! { |cur| cur.id == id }
      res.count.should == 1
      res.first.deleted.should == deleted
    end

    def check_no_entity_evt(entity_set, id)
      res = EntityEventStore.get_events_since(entity_set, Time.now.to_i - 1)
      res.select! { |cur| cur.id == id }
      res.count.should == 0
    end

    def create_session_with_user(user)
      password = 'badwolf'
      user.password_sha256 = Digest::SHA256.hexdigest password
      user.save

      login = {
        username: user.username,
        password: password,
      }
      anon_identity = IdentityAnonymous.new

      Users::CreateSession.new(anon_identity).run(login)
    end

    def create_identity_with_user(user)
      session = Users::Session.get create_session_with_user(user)[:id]
      IdentityUser.new session 
    end

    def login_with_user(user)
      session = create_session_with_user user

      clear_cookies
      set_cookie 'session_id=' + session[:id]
    end

    def webdav_auth(user = nil)
      password = '123test'
      user ||= Factory Users::User, 
        position_group: :teacher, admin_group: :super

      user.password_sha256 = Digest::SHA256.hexdigest password
      user.save

      authorize user.username, password
    end
  end

  class StubEntity
    class StubErrors
      def full_messages
        [ 'a', 'b' ]
      end
    end

    attr_accessor :valid

    def valid?
      @valid
    end

    def errors
      StubErrors.new
    end

    def self.ancestors
      [ DataMapper::Resource ]
    end
  end

end

