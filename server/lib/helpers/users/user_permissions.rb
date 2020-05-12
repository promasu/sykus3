module Sykus; module Users

  # Gets array of user permissions for a specific user.
  module UserPermissions
    include Config::Permissions

    # @param [User] user User entity instance.
    # @return [Array] Array of permission symbols.
    def self.get(user)
      raise Exceptions::Input unless user.is_a? User 

      permission_list = 
        case user.position_group
        when :person
          PositionPerson
        when :student
          PositionStudent
        when :teacher
          PositionTeacher
        end

      case user.admin_group
      when :senior, :super
        permission_list += PositionTeacher
      end

      permission_list +=
        case user.admin_group
        when :none
          []
        when :junior
          AdminJunior
        when :senior
          AdminSenior
        when :super
          AdminSuper
        end

      # special case, students should never have access to teacher share
      if user.position_group == :student
        permission_list.delete :share_teacher_access
      end

      permission_list.to_a
    end
  end

end; end

