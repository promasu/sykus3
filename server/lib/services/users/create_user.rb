require 'common'

require 'jobs/users/create_nss_db_job'
require 'jobs/users/update_samba_job'
require 'jobs/users/update_homedir_job'
require 'jobs/users/update_radius_users_job'

require 'services/users/password_reset'

module Sykus; module Users

  # Creates a new User.
  class CreateUser < ServiceBase

    # `:username` is optional and will be auto-generated if not present.
    # @param [Hash] args Hash of new user attributes. 
    # @return [Hash/Integer] User ID.
    def action(args)
      enforce_permission! :users_write

      user = User.new select_args(args, [ :username, :birthdate,
                                  :position_group, :admin_group ]) 
      user.full_name = FullUserName.new(args[:first_name], args[:last_name])

      # changed after creation by reset call
      user.password_expired = true
      user.password_nt = 'a' * 32
      user.password_sha256 = 'a' * 64

      user.user_class = nil
      if args[:user_class] && user.position_group == :student
        user.user_class = UserClass.get(args[:user_class].to_i)
      end

      validate_entity! user
      CheckSystemUser.enforce! user.username
      enforce_permission! :users_write_admin unless user.admin_group == :none

      user.save
      entity_evt = EntityEvent.new(EntitySet.new(User), user.id, false)
      EntityEventStore.save entity_evt

      Resque.enqueue CreateNSSDBJob
      Resque.enqueue UpdateRADIUSUsersJob
      Resque.enqueue UpdateHomedirJob, user.id
      Resque.enqueue UpdateSambaJob, user.username

      reset = PasswordReset.new(@identity).run(user.id)

      { id: user.id }.merge reset
    end
  end

end; end

