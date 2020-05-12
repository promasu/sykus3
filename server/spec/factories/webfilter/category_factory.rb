require 'common'

module Sykus

  Factory.define Webfilter::Category do |category|
    category.name 'category/c%d'
    category.text 'Description text.'
    category.default :students
    category.selected :all
  end

end

