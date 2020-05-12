module Sykus; module Calendar

  # Gets access permissions for a certain user/cal_id pair
  module CalendarPermission
    # Returns permission symbol (either: none, read, write, admin)
    # @param [Identity] identity User identity.
    # @param [String] cal_id Calendar ID.
    # @param [User] user User object (optional, for performance reasons).
    # @return [Symbol] Permission symbol.
    def self.get(identity, cal_id, user = nil)
      type, id = cal_id.split(':')

      id = id.to_i
      type = type.to_sym

      user ||= Users::User.get(identity.user_id)
      raise if user.nil?

      permissions = identity.permissions

      case type
      when :private
        return id == user.id ? :admin : :none

      when :teacher
        return :admin if permissions.include? :calendar_teacher_admin
        return :write if permissions.include? :calendar_teacher_write
        return :read if permissions.include? :calendar_teacher_read
        return :none

      when :global
        return :admin if permissions.include? :calendar_global_admin
        return :write if permissions.include? :calendar_global_write
        return :read

      when :grade
        return :admin if permissions.include? :calendar_grade_admin
        return :write if permissions.include? :calendar_grade_write
        return :read if permissions.include? :calendar_grade_read
        return :read if user.user_class && user.user_class.grade == id
        return :none

      when :group
        group = Users::UserGroup.get(id)
        raise Exceptions::NotFound if group.nil?
        return :admin if permissions.include? :calendar_group_admin
        return :admin if group.owner == user
        return :write if group.users.include? user
        return :none 

      when :class
        user_class = Users::UserClass.get(id)
        raise Exceptions::NotFound if user_class.nil?
        return :admin if permissions.include? :calendar_class_admin
        return :write if permissions.include? :calendar_class_write
        return :read if permissions.include? :calendar_class_read
        return :read if user.user_class == user_class
        return :none 

      when :resource
        return :admin if permissions.include? :calendar_resource_admin
        return :write if permissions.include? :calendar_resource_write
        return :read if permissions.include? :calendar_resource_read
        return :none

      else 
        raise Exceptions::Input, 'Invalid type'
      end
    end
    end

  end; end

