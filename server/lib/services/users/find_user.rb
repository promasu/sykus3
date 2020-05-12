require 'common'


module Sykus; module Users

  # Finds Users.
  class FindUser < ServiceBase

    # Find user given their user id.
    # @param [Integer] uid User ID.
    # @return [Hash] User data.
    def by_id(uid)
      enforce_permission! :users_read
      export_user User.get(uid)
    end

    # Find user given their user name.
    # @param [String] name User name.
    # @return [Hash] User data.
    def by_name(name)
      enforce_permission! :users_read
      export_user User.first(username: name)
    end

    # Find all users.
    # @return [Array] Array of user data.
    def all
      enforce_permission! :users_read

#      CachedQuery.get_cached(User.all, EntitySet.new(User)) do |obj|
 #       export_user obj
  #    end

      User.all.map { |user| export_user user }
    end

    private 
    def export_user(user)
      raise Exceptions::NotFound, 'User not found' if user.nil?

      data = select_entity_props(user, [ :id, :username, :birthdate ])

      if @identity.permissions.include? :users_read_password_initial 
        data.merge! password_initial: user.password_initial
      end

      data.merge({ 
        first_name: user.full_name.first_name,
        last_name: user.full_name.last_name,
        position_group: user.position_group.to_s,
        admin_group: user.admin_group.to_s,
        quota_used_mb: user.quota_used_mb, 
        quota_total_mb: Users::GetUserMaxQuota.get(user),
        user_class: user.user_class ? user.user_class.id : nil,
      })
    end
  end

end; end
