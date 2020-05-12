require 'common'

module Sykus

  Factory.define Calendar::Event do |event|
    event.title 'event%d'
    event.start DateTime.now
    event.end DateTime.now + 3600
    event.all_day false
    event.type :private
    event.user { Factory Users::User }
  end

end

