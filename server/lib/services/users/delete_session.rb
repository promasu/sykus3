require 'common'

require 'jobs/webfilter/update_nonstudents_list_job'

module Sykus; module Users

  # Deletes a user session (aka. logging out).
  class DeleteSession < ServiceBase

    # @param [String] id Session ID.
    def run(id)
      # No need to check for permission. If an attacker has the session id
      # everything is lost anyway.

      raise Exceptions::Input unless id.is_a? String

      session = Session.get id.strip
      session.destroy unless session.nil?

      Resque.enqueue Webfilter::UpdateNonStudentsListJob

      nil
    end
  end

end; end

