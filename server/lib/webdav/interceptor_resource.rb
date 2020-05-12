require 'common'
require 'dav4rack/interceptor_resource'

module Sykus; module WebDAV

  # Root dir interceptor, provides different shares / directories.
  class InterceptorResource < DAV4Rack::InterceptorResource
    include AuthResource
    include DAV4Rack::HTTPStatus

    # Set mappings when authenticated.
    def authenticate(username, password)
      result = super
      set_mappings if @mappings.empty? && result
      result
    end

    # Interceptor goes only one level deep, digging further results in errors.
    def descendants
      children
    end

    private
    def set_mappings
      @options[:resource_list].each do |resource|
        instance = resource.new('/', '/', nil, nil, { user: @user })
        @mappings[resource.basepath] = resource if instance.user_readable?
      end

      @root_paths = @mappings.keys
    end
  end

end; end


