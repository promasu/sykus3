require 'common'

module Sykus; module WebDAV

  class ResourceHome < Resource
    def root
      user ? "/home/users/u#{user.id}" : '/DOESNOTEXIST'
    end

    def user_readable?
      true
    end

    def user_writable?
      true
    end
  end

end; end

