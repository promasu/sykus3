require 'common'

module Sykus; module WebDAV

  class ResourceShareTeacher < Resource
    def root
      '/home/share/teacher'
    end

    def user_readable?
      user_writable?
    end

    def user_writable?
      user_permissions.include? :share_teacher_access
    end
  end

end; end

