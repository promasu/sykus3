require 'common'

require 'jobs/users/create_nss_db_job'
require 'jobs/users/update_samba_job'
require 'jobs/users/update_homedir_job'
require 'jobs/users/update_radius_users_job'

module Sykus; module Users

  # Updates a User.
  class UpdateUser < ServiceBase

    # @param [Integer] id User ID.
    # @param [Hash] args Hash of new user attributes. 
    def action(id, args)
      enforce_permission! :users_write

      id = id.to_i
      user = User.get(id)
      raise Exceptions::NotFound, 'User not found' if user.nil?

      old_username = user.username
      old_admin_group = user.admin_group

      user.attributes = select_args(args, [ :username, :birthdate, 
                                    :position_group, :admin_group ])

      first_name = args[:first_name] || user.full_name.first_name
      last_name = args[:last_name] || user.full_name.last_name
      user.full_name = FullUserName.new(first_name, last_name)

      user.username = args[:username] if args[:username]

      user.user_class = nil unless user.position_group == :student
      if args[:user_class]
        uc = UserClass.get(args[:user_class].to_i)
        raise Exceptions::Input, 'User class not found' if uc.nil?
        user.user_class = uc
      end

      validate_entity! user
      CheckSystemUser.enforce! user.username
      unless user.admin_group == old_admin_group
        enforce_permission! :users_write_admin
        if @identity.user_id == user.id
          raise Exceptions::Input, 'You cannot change your own admin group'
        end
      end

      user.save
      entity_evt = EntityEvent.new(EntitySet.new(User), user.id, false)
      EntityEventStore.save entity_evt

      Resque.enqueue CreateNSSDBJob
      Resque.enqueue UpdateRADIUSUsersJob
      Resque.enqueue UpdateHomedirJob, user.id

      Resque.enqueue UpdateSambaJob, user.username
      unless user.username == old_username
        Resque.enqueue UpdateSambaJob, old_username
      end

      nil
    end
  end

end; end

