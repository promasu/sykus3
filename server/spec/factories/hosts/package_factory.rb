require 'common'

module Sykus

  Factory.define Hosts::Package do |package|
    package.id_name 'pack%d'
    package.name 'Package %d'
    package.text 'Description text.'
    package.category 'Category'
    package.default true
    package.selected true
    package.installed false
  end

end

