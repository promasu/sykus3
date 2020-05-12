require 'common'

module Sykus

  Factory.define Users::Session do |session|
    session.id { SecureRandom.hex 32 }
    session.user { Factory Users::User }
    session.host nil
  end

end

