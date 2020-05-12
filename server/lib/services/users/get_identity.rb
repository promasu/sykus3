require 'common'


module Sykus; module Users

  # Gets the current user identity.
  class GetIdentity < ServiceBase

    # @return [Hash] Hash with all identity data.
    def run
      raise unless @identity.is_a? IdentityUser

      user = Users::User.get(@identity.user_id)
      user_props = [ :id, :username, :first_name, :last_name,
        :quota_used_mb, :position_group, :admin_group,
      ]

      {
        user: select_entity_props(user, user_props),
        permissions: @identity.permissions,
      }
    end
  end

end; end

