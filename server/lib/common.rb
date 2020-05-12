# Main application module.
module Sykus

  raise if defined? APP_ENV

  # Application environment. 
  APP_ENV = 
    if defined? TEST_ENV
      :test
    elsif File.exists?(File.dirname(__FILE__) + '/../ENV_PRODUCTION')
      :prod
    else
      :dev
    end

  # Require StdLib modules/classes.
  require 'date'
  require 'digest'
  require 'ipaddr'
  require 'openssl'
  require 'socket'
  require 'tempfile'
  require 'time'
  require 'timeout'
  require 'fileutils'
  require 'securerandom'
  require 'set'
  require 'uri'
  require 'yaml'

  # Import all gems into environment, but require only those that are needed.
  require 'bundler'
  Bundler.setup
  Bundler.require :default, APP_ENV

  # Require selected activesupport libs.
  require 'active_support/inflector'
  require 'active_support/time'

  # Sub-includes
  require 'includes/simplecov' if defined? SIMPLECOV
  require 'includes/logger'

  begin
    require 'config/i18n'
    require 'config/permissions'
    require 'config/quota'
    require 'includes/exceptions'
    require 'includes/entities'
    require 'includes/helpers'
    require 'includes/objects'
    require 'includes/redis'
    require 'includes/resque'
  rescue Exception => e
    LOG.exception 'common.rb', e
    raise e
  end

  #
  # Submodules
  # (for documentation purposes; only if not documented in module base file)
  # 

  # Globally included modules and helpers.
  module Includes; end

  # Configuration.
  module Config; end

  # Host-specific classes and modules.
  module Hosts; end

  # User-specific classes and modules.
  module Users; end

  # Teacher related function modules.
  module Teacher; end

  # Printers.
  module Printers; end

  # Logs.
  module Logs; end

  # Webfilter.
  module Webfilter; end

  # WebIF Dashboard views.
  module Dashboards; end

  # File retrieval.
  module Files; end

  # Calendar module.
  module Calendar; end

end

