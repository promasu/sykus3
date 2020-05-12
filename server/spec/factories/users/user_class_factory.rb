require 'common'

module Sykus

  Factory.define Users::UserClass do |user_class|
    user_class.name '7c%d'
    user_class.grade 7
  end

end

