require 'common'

require 'jobs/users/update_group_shares_job'
require 'jobs/users/create_nss_db_job'

module Sykus; module Users

  # Creates a new User Group.
  class CreateUserGroup < ServiceBase

    # @param [Hash] args Hash of new user group attributes. 
    # @return [Hash/Integer] User Group ID.
    def action(args)
      owner = User.get(args[:owner].to_i)
      raise Exceptions::Input, 'Owner user not found' if owner.nil?

      if owner.id == @identity.user_id
        enforce_permission! :user_groups_write_own
      else
        enforce_permission! :user_groups_write
      end

      ug = UserGroup.new select_args(args, [ :name ])
      ug.owner = owner
      ug.users = [ owner ]

      unless args[:users].is_a? Array
        raise Exceptions::Input, 'users must be an array'
      end
      args[:users].each do |id|
        user = User.get(id.to_i)
        raise Exceptions::Input, 'Member user not found' if user.nil?
        ug.users << user
      end

      validate_entity! ug

      ug.save
      entity_evt = EntityEvent.new(EntitySet.new(UserGroup), ug.id, false)
      EntityEventStore.save entity_evt
      Resque.enqueue UpdateGroupSharesJob
      Resque.enqueue CreateNSSDBJob

      { id: ug.id }
    end
  end

end; end

