require 'common'


module Sykus; module Users

  # Deletes a User Class.
  class DeleteUserClass < ServiceBase

    # @param [Integer] id User Class ID.
    def action(id)
      enforce_permission! :user_classes_write

      uc = UserClass.get(id.to_i)
      raise Exceptions::NotFound, 'User class not found' if uc.nil?

      if Users::User.count(user_class: uc) > 0
        raise Exceptions::Input, 'User class not empty'
      end

      # clear calendar events
      uc.events.destroy

      uc.destroy
      entity_evt = EntityEvent.new(EntitySet.new(UserClass), id.to_i, true)
      EntityEventStore.save entity_evt
    end
  end

end; end

