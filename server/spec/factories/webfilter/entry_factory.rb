require 'common'

module Sykus

  Factory.define Webfilter::Entry do |entry|
    entry.domain 'example%d.com'
    entry.comment 'comment'
    entry.type :black_all
  end

end

