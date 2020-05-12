require 'common'

module Sykus; module Api

  # Api Identity methods.
  class App
    helpers do
      def get_identity(no_test_identity = false)
        if APP_ENV == :test && !no_test_identity
          return IdentityTestGod.new
        end

        session_id = request.cookies['session_id']
        raise Exceptions::Input unless session_id.is_a? String
        session = Users::Session.get session_id.strip
        raise Exceptions::NotFound if session.nil?

        IdentityUser.new session
      rescue Exceptions::NotFound, Exceptions::Input
        halt [ 401, 'Invalid session'.to_json ]
      end

      def sni_get_identity
        session_id = params[:session]
        raise Exceptions::Input unless session_id.is_a? String
        session = Users::Session.get session_id.strip
        raise Exceptions::NotFound if session.nil?

        IdentityUser.new session
      rescue Exceptions::NotFound, Exceptions::Input
        halt 'err:invalidsession'
      end
    end
  end

end; end

