require 'common'

module Sykus; module WebDAV

  # Use DB backed user auth for a resource.
  module AuthResource
    include DAV4Rack::HTTPStatus

    # Inherit user entity.
    def setup
      @user = nil unless user.is_a? Users::User
    end

    protected
    def user_permissions
      return [] unless user
      @user_permissions ||= Users::UserPermissions.get(user)
    end

    def authenticate(username, password)
      if user.nil? && username.is_a?(String) && password.is_a?(String)
        hash = Digest::SHA256.hexdigest password 
        @user = Users::User.first username: username,
          password_expired: false, password_sha256: hash 
        @user ||= false
      end

      !!user
    end
  end

end; end

