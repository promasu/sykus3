require 'common'

module Sykus

  Factory.define Users::UserGroup do |user_group|
    user_group.name 'Some Group'
    user_group.owner { Factory Users::User }
    user_group.users []
  end

end

