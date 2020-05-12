require 'common'

module Sykus

  Factory.define Logs::SessionLog do |log|
    log.username 'user42'
    log.type :login
    log.ip nil
    log.created_at { DateTime.now }
  end

end

