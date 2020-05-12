require 'common'

require 'webdav/controller'

require 'webdav/auth_resource'
require 'webdav/resource'
require 'webdav/interceptor_resource'

require 'webdav/resources/resource_home'
require 'webdav/resources/resource_groups'
require 'webdav/resources/resource_share_progdata'
require 'webdav/resources/resource_share_admin'
require 'webdav/resources/resource_share_teacher'

require 'webdav/app'

module Sykus

  # WebDAV file access server.
  module WebDAV; end

end 

