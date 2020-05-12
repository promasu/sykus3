require 'spec_helper'

module Sykus

  describe Config::Permissions do
    p = Config::Permissions

    [
      p::PositionPerson,
      p::PositionStudent,
      p::PositionTeacher,

      p::AdminNone,
      p::AdminJunior,
      p::AdminSenior,
      p::AdminSuper

    ].each do |list|
      it 'has correct list contents' do
        list.should be_a Set
        list.each do |perm|
          Config::Permissions::PermissionList.should include perm
        end
      end
    end
  end

end

