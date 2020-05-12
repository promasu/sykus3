require 'common'

module Sykus; module WebDAV

  # List of all exposed resource types.
  RESOURCE_LIST = [
    ResourceHome,
    ResourceGroups,
    ResourceShareProgdata,
    ResourceShareAdmin,
    ResourceShareTeacher,
  ]

  # Get the WebDAV Rack app.
  def self.app
    # WARNING: no trailing backslashes for paths, 
    # it breaks non-standard clients
    Rack::Builder.new do
      RESOURCE_LIST.each do |resource|
        [ resource.basepath, resource.basepath_internal ].each do |path|
        map path do
          run DAV4Rack::Handler.new({
            controller_class: Sykus::WebDAV::Controller,
            resource_class: resource,
            root_uri_path: path,
            always_include_dav_header: true,
          })
        end
        end
      end

      map '/dav' do
        run DAV4Rack::Handler.new({
          controller_class: Sykus::WebDAV::Controller,
          resource_class: Sykus::WebDAV::InterceptorResource,
          resource_list: RESOURCE_LIST,
          mappings: {},
          always_include_dav_header: true,
        })
      end
    end.to_app
  end

end; end

