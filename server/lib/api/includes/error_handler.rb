require 'common'

module Sykus; module Api

  class App
    # Route exception wrapper. Use inside a route-block.
    # When used with a block, it rescues all app-specific
    # exceptions and returns meaningful HTTP responses.
    def exception_wrapper
      yield
    rescue Exceptions::Input => e
      [ 400, e.to_s.to_json ]
    rescue Exceptions::NotFound => e
      [ 404, e.to_s.to_json ]
    rescue Exceptions::Permission => e
      [ 401, e.to_s.to_json ]
    rescue Exception => e
      LOG.exception 'API Inside', e
      500
    end

    # Route exception wrapper for SNI requests.
    # Use plaintext output instead of JSON.
    def sni_exception_wrapper(&block)
      yield
    rescue Exceptions::NotFound
      'err:notfound'
    rescue Exceptions::Input
      'err:input'
    rescue Exception => e
      LOG.exception 'SNI API', e
      'err:internal'
    end

  end

end; end

