require 'common'

require 'api/includes/base'
require 'api/includes/helpers'
require 'api/includes/error_handler'
require 'api/includes/identity'

require 'api/common/demodata'

require 'api/config/config'
require 'api/config/public_config'

require 'api/teacher/roomctl'

require 'api/users/user'
require 'api/users/user_group'
require 'api/users/user_class'
require 'api/users/session'
require 'api/users/identity'
require 'api/users/import'
require 'api/users/auth'
require 'api/users/change_password'

require 'api/hosts/sni'
require 'api/hosts/host'
require 'api/hosts/host_group'
require 'api/hosts/package'
require 'api/hosts/image'
require 'api/hosts/cli'

require 'api/printers/printer'
require 'api/printers/printer_helper'

require 'api/webfilter/category'
require 'api/webfilter/search'
require 'api/webfilter/entry'

require 'api/logs/logs'

require 'api/dashboards/dashboards'

require 'api/files/get_file'

require 'api/calendar/event'
require 'api/calendar/calendars'
require 'api/calendar/resource'

module Sykus

  # RESTful API classes and modules.
  module Api; end

end 

