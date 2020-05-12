require 'common'

require 'jobs/users/update_group_shares_job'
require 'jobs/users/delete_group_share_job'
require 'jobs/users/create_nss_db_job'

module Sykus; module Users

  # Deletes a User Group.
  class DeleteUserGroup < ServiceBase

    # @param [Integer] id User Group ID.
    def action(id)
      ug = UserGroup.get(id.to_i)
      raise Exceptions::NotFound, 'User group not found' if ug.nil?

      if ug.owner && @identity.user_id == ug.owner.id
        enforce_permission! :user_groups_write_own
      else
        enforce_permission! :user_groups_write
      end

      # clear calendar events
      ug.events.destroy

      # clear many-to-many relationship
      ug.users = []
      ug.save

      ug.destroy

      entity_evt = EntityEvent.new(EntitySet.new(UserGroup), id.to_i, true)
      EntityEventStore.save entity_evt
      Resque.enqueue UpdateGroupSharesJob
      Resque.enqueue DeleteGroupShareJob, id.to_i
      Resque.enqueue CreateNSSDBJob
      nil
    end
  end

end; end

