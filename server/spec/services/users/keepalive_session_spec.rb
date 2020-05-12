require 'spec_helper'

require 'services/users/keepalive_session'

module Sykus

  describe Users::KeepaliveSession do
    let (:keepalive_session) {
      Users::KeepaliveSession.new IdentityTestGod.new
    }
    let (:session) { Factory Users::Session, updated_at: DateTime.now - 1 } 

    it 'refreshes a session' do
      old = session.updated_at
      keepalive_session.run session.id

      Users::Session.get(session.id).updated_at.should be > old
    end

    it 'fails on invalid session' do
      expect {
        keepalive_session.run 'b' * 64
      }.to raise_error Exceptions::NotFound
    end
  end

end

