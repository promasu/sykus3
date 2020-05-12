require 'common'

module Sykus

  Factory.define Logs::ServiceLog do |log|
    log.username 'user42'
    log.service 'service'
    log.input 'in'
    log.output 'out'
    log.created_at { DateTime.now }
  end

end

