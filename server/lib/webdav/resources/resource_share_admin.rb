require 'common'

module Sykus; module WebDAV

  class ResourceShareAdmin < Resource
    def root
      '/home/share/admin'
    end

    def user_readable?
      user_writable?
    end

    def user_writable?
      user_permissions.include? :share_admin_access
    end
  end

end; end

