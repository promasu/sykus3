require 'common'


module Sykus; module Users

  # Finds User Groups.
  class FindUserGroup < ServiceBase

    # Find user group given the id.
    # @param [Integer] id User group ID.
    # @return [Hash] User group data.
    def by_id(id)
      enforce_permission! :user_groups_read
      export_ug UserGroup.get(id)
    end

    # Find all user groups.
    # @return [Array] Array of user group data.
    def all
      enforce_permission! :user_groups_read
      UserGroup.all.map { |ug| export_ug ug }
    end

    # Find all user groups that belong to the current identity.
    # @return [Array] Array of user group data.
    def own
      enforce_permission! :user_groups_read

      owner = User.get(@identity.user_id)
      raise Exceptions::Input if owner.nil?

      UserGroup.all(owner: owner).map { |ug| export_ug ug }
    end

    private 
    def export_ug(ug)
      raise Exceptions::NotFound, 'User group not found' if ug.nil?

      data = select_entity_props(ug, [ :id, :name ])
      data.merge({ 
        owner: ug.owner ? ug.owner.id : nil,
        users: ug.users.map(&:id),
      })
    end
  end

end; end
