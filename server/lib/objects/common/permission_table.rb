module Sykus

  # Class that represents all permission an Identity can have
  # and whether owner has been granted those permissions.
  class PermissionTable
    # List of all current permission symbols.
    PermissionList = Config::Permissions::PermissionList

    # Create a permission list with all permissions disabled.
    def initialize
      @permissions = Set.new
    end

    # Returns a regular array of all enabled permissions.
    # @return [Array] Array of permissions.
    def permissions
      @permissions.to_a
    end

    # Set the permission flag to the specified value.
    # @param [Symbol] permission Permission symbol.
    # @param [Boolean] flag Flag.
    def set(permission, flag)
      raise unless PermissionList.include? permission
      if flag
        @permissions.add permission
      else
        @permissions.delete permission
      end
    end

    # Gets the permission flag for the given Symbol
    # @param [Symbol] permission Permission flag.
    # @return [Boolean] Flag.
    def get(permission)
      raise unless PermissionList.include? permission
      @permissions.include? permission
    end

    # Enable all permissions.
    def enable_all
      @permissions = Set.new PermissionList
    end
  end

end

