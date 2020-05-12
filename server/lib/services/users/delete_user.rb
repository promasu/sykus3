require 'common'

require 'services/users/delete_user_group'

require 'jobs/users/create_nss_db_job'
require 'jobs/users/update_samba_job'
require 'jobs/users/update_homedir_job'
require 'jobs/users/update_radius_users_job'

module Sykus; module Users

  # Deletes a User.
  class DeleteUser < ServiceBase

    # @param [Integer] id User ID.
    def action(id)
      enforce_permission! :users_write

      id = id.to_i
      user = User.get(id)
      raise Exceptions::NotFound, 'User not found' if user.nil?

      if @identity.user_id == user.id
        raise Exceptions::Input, 'You cannot delete yourself'
      end

      username = user.username

      enforce_permission! :users_write_admin unless user.admin_group == :none

      # delete all user groups where this user is owner
      UserGroup.all(owner: user).each do |ug|
        DeleteUserGroup.new(@identity).run(ug.id)
      end

      # delete all calendar events
      user.events.destroy

      # delete all sessions
      user.sessions.destroy

      # clear many-to-many relationship
      user.user_groups = []
      user.save

      user.destroy
      entity_evt = EntityEvent.new(EntitySet.new(User), id, true)
      EntityEventStore.save entity_evt

      Resque.enqueue CreateNSSDBJob
      Resque.enqueue UpdateRADIUSUsersJob
      Resque.enqueue UpdateHomedirJob, id
      Resque.enqueue UpdateSambaJob, username

      nil
    end
  end

end; end
