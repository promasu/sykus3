require 'common'

require 'jobs/users/update_group_shares_job'
require 'jobs/users/create_nss_db_job'

module Sykus; module Users

  # Updates a User Group.
  class UpdateUserGroup < ServiceBase

    # @param [Integer] id User group ID.
    # @param [Hash] args Hash of new user group attributes. 
    def action(id, args)
      ug = UserGroup.get(id.to_i)
      raise Exceptions::NotFound, 'User Group not found' if ug.nil?

      if ug.owner.id == @identity.user_id
        enforce_permission! :user_groups_write_own
      else
        enforce_permission! :user_groups_write
      end

      ug.name = args[:name] if args[:name]

      if args[:owner]
        owner = User.get(args[:owner].to_i)
        raise Exceptions::Input, 'Owner user not found' if owner.nil?

        enforce_permission! :user_groups_write unless ug.owner == owner
        ug.owner = owner
        ug.users << owner
      end 

      if args[:users].is_a? Array
        ug.users = [ ug.owner ]
        args[:users].each do |uid|
          user = User.get uid.to_i
          raise Exceptions::Input, 'Member user not found' if user.nil?
          ug.users << user
        end
      end

      validate_entity! ug

      ug.save
      entity_evt = EntityEvent.new(EntitySet.new(UserGroup), ug.id, false)
      EntityEventStore.save entity_evt
      Resque.enqueue UpdateGroupSharesJob
      Resque.enqueue CreateNSSDBJob
      nil
    end
  end

end; end

