module Sykus

  # User or API Identity helper class.
  class IdentityBase
    def initialize
      raise 'Abstract base class'
    end

    # Returns a list of permissions of the current identity.
    def permissions
      @permission_table.permissions
    end

    # Enforces that the current identity has the given permission.
    # @param [Symbol] permission Permission symbol.
    def enforce_permission!(permission)
      return if @permission_table.get permission
      raise Exceptions::Permission.new(permission)
    end
  end

  # User identity.
  class IdentityUser < IdentityBase
    attr_reader :user_id, :admin_session

    # Create a new user identity
    # @param [Session] session User Session instance.
    def initialize(session)
      raise unless session.is_a? Users::Session
      @user_id = session.user.id

      @user = Users::User.get(@user_id)
      raise Exceptions::NotFound, 'User not found' if @user.nil?

      permission_list = Users::UserPermissions.get(@user)

      @permission_table = PermissionTable.new
      permission_list.each do |permission|
        @permission_table.set(permission, true)
      end
    end

    # Returns user name and id.
    def name
      "#{@user.username}[#{@user.id.to_s}]"
    end
  end

  # God identity with all permissions (testing only)
  class IdentityTestGod < IdentityBase
    attr_accessor :permission_table, :user_id

    def initialize
      @permission_table = PermissionTable.new
      @permission_table.enable_all
    end

    # Remove all permissions except for one
    # @param [Symbol] permission Permission symbol. May be nil.
    def only_permission(permission)
      @permission_table = PermissionTable.new
      @permission_table.set(permission, true) if permission
    end

    # Constant name.
    def name; 'Testing Identity'; end
  end

  # Anonymous identity (no permissions).
  class IdentityAnonymous < IdentityBase
    def initialize
      @permission_table = PermissionTable.new
    end

    # Constant name.
    def name; 'Anonymous'; end
  end

end
