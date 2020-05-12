require 'common'

module Sykus

  Factory.define Config::Value do |value|
    value.name 'config%d'
    value.json_value '"data"'
  end

end

