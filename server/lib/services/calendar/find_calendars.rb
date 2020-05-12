require 'common'

module Sykus; module Calendar

  # Finds Calendars.
  class FindCalendars < ServiceBase

    # Returns a list of all calendars the user has at least read access to.
    # @return [Hash] Hash of calendar id -> permissions pairs.
    def all
      user = Users::User.get(@identity.user_id)
      permissions = @identity.permissions

      list = %w{global teacher}
      list << "private:#{user.id}"

        user.user_groups.each do |ug|
        list << "group:#{ug.id}"
        end

      if (permissions.include?(:calendar_class_read) ||
          permissions.include?(:calendar_class_write) ||
          permissions.include?(:calendar_class_admin))
        Users::UserClass.all.each do |uc|
          list << "class:#{uc.id}"
            list << "grade:#{uc.grade}"
        end
      end

      if user.user_class
        list << "class:#{user.user_class.id}"
          list << "grade:#{user.user_class.grade}"
      end

      if (permissions.include?(:calendar_resource_read) ||
          permissions.include?(:calendar_resource_write) ||
          permissions.include?(:calendar_resource_admin))
        Calendar::Resource.all.each do |res|
          list << "resource:#{res.id}"
        end
      end

      res = {}
      list.uniq.each do |cal_id|
        perm = CalendarPermission.get(@identity, cal_id, user)
        next if perm == :none

        res[cal_id] = perm
      end

      res
    end
  end

end; end

