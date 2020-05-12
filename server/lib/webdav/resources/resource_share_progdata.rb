require 'common'

module Sykus; module WebDAV

  class ResourceShareProgdata < Resource
    def root
      '/home/share/progdata'
    end

    def user_readable?
      true
    end

    def user_writable?
      user_permissions.include? :share_progdata_write
    end
  end

end; end

