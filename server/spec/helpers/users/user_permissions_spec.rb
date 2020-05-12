require 'spec_helper'

module Sykus

  describe Users::UserPermissions do
    let! (:user) { Factory Users::User }

    p = Config::Permissions

    [ :person, :student, :teacher ].each do |position|
      position_permissions = 
        case position
        when :person
          p::PositionPerson
        when :student
          p::PositionStudent
        when :teacher
          p::PositionPerson + p::PositionTeacher
        end

      [
        [ position, :none,   [] ],
        [ position, :junior, p::AdminJunior ],
        [ position, :senior, p::PositionTeacher + p::AdminSenior ],
        [ position, :super,  p::PositionTeacher + p::AdminSuper ],
      ].each do |test|
        position, admin, admin_permissions = *test

        it "works for #{position} / #{admin}" do
          user.position_group = position
          user.admin_group = admin

          permissions = position_permissions + admin_permissions

          # special case
          if position == :student
            permissions.delete :share_teacher_access
          end

          Users::UserPermissions.get(user).should =~ permissions.to_a
        end
      end
    end

    it 'raises on invalid user' do
      expect { 
        Users::UserPermissions.get({}) 
      }.to raise_error Exceptions::Input
    end
  end

end

