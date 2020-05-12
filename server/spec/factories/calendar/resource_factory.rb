require 'common'

module Sykus

  Factory.define Calendar::Resource do |res|
    res.name 'resource%d'
    res.active true
  end

end

