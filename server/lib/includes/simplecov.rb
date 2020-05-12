module Sykus

  # Set output to webif subdir, so it gets exposed on webserver.
  SimpleCov.coverage_dir('../webif/coverage')
  SimpleCov.start do
    add_filter '.bundle/'
    add_filter 'lib/includes'
    add_filter 'lib/config'

    add_group 'API', 'lib/api'
    add_group 'WebDAV', 'lib/webdav'
    add_group 'Entities', 'lib/entities'
    add_group 'Objects', 'lib/objects'
    add_group 'Services', 'lib/services'
    add_group 'Jobs', 'lib/jobs'
    add_group 'Helpers', 'lib/helpers'
    add_group 'Specs', 'spec'
  end

end

