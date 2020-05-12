require 'common'
require 'dav4rack/resources/file_resource'

module Sykus; module WebDAV

  class Resource < DAV4Rack::FileResource
    include AuthResource
    include DAV4Rack::HTTPStatus

    def self.basepath_internal
      '/dav/' + self.name.demodulize.downcase
    end

    def self.basepath
      name = self.name.demodulize
      '/dav/' + (Config::I18n::WEBDAV_BASEPATHS[name] || name)
    end

    def exist?
      ::File.exist?(file_path) && ::File.exist?(::File.realpath(file_path))
    end

    # Must be overridden.
    def root
      raise
    end

    def children
      super.select do |child|
        begin
          child.check_valid_path
          child.exist? && child.user_readable?
        rescue Forbidden
          false
        end
      end
    end

    def chown!
      raise Forbidden unless user
      return unless exist?
      ::File.chown(@user.system_id, nil, file_path)
      ::File.chmod(0777, file_path)
    end

    def check_prefix(path)
      ::File.join(path, '/').start_with? ::File.join(root, '/')
    end

    def check_valid_path
      raise Forbidden unless check_prefix file_path
      if exist?
        raise Forbidden unless check_prefix ::File.realpath(file_path)
      end
    end

    def put(request, response)
      raise Forbidden unless user_writable?
      result = super
      chown!
      result
    end

    def post(request, response)
      put(request, response)
    end

    def delete
      raise Forbidden unless user_writable?
      super
    end

    def copy(dest, overwrite)
      raise Forbidden unless user_writable?
      raise Forbidden unless dest.user_writable?

      result = super
      dest.chown!
      result
    end

    def make_collection
      raise Forbidden unless user_writable?
      result = super
      chown!
      result
    end

    def get(request, response)
      raise Forbidden unless user_readable?

      # no HTML view of directories
      raise Forbidden if stat.directory?

      super
    end

    def authenticate(username, password)
      result = super
      check_valid_path
      result
    end

  end

end; end

