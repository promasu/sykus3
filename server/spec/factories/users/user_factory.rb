require 'common'

module Sykus

  Factory.define Users::User do |user|
    user.username 'lumberghbill%d'
    user.full_name Users::FullUserName.new('Bill', 'Lumbergh')
    user.birthdate '11.05.2011'

    user.password_expired false
    user.password_nt ('a' * 32)
    user.password_sha256 ('a' * 64)

    user.position_group :person
    user.admin_group :none
  end

end

