require 'common'


module Sykus; module Users

  # Refreshes timeout of a session.
  class KeepaliveSession < ServiceBase

    # @param [String] id Session ID.
    def run(id)
      # No need to check for permission. If an attacker has the session id
      # everything is lost anyway.

      raise Exceptions::Input unless id.is_a? String

      session = Session.get id.strip
      raise Exceptions::NotFound if session.nil?

      # force updated_at time (does not get updated if object has not changed)
      session.updated_at = DateTime.now
      session.save
      nil
    end
  end

end; end

