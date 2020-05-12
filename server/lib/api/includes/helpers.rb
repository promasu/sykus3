require 'common'

module Sykus; module Api

  # Api Helper methods.
  class App
    helpers do
      def json_request
        JSON.parse(request.body.read, { symbolize_names: true })
      rescue
        raise Exceptions::Input, 'Invalid JSON data'
      end

      def get_ip(raise_on_error = true)
        # we cannot use #request.ip because it filters the
        # X-Forwarded-For header for 10.0.0.0/8 requests.
        IPAddr.new @env['HTTP_X_FORWARDED_FOR'] 
      rescue
        return nil unless raise_on_error
        raise Exceptions::Input, 'Cannot get remote IP.'
      end
    end
  end

end; end

