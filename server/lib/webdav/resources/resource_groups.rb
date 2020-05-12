require 'common'

module Sykus; module WebDAV

  class ResourceGroups < Resource
    def root
      '/home/groups'
    end

    def user_readable?
      return true if file_path.chomp('/') == root
      user_writable?
    end

    def user_writable?
      return false unless user

      if exist?
        stat = File.stat file_path
      else
        dir = File.dirname(file_path.chomp('/'))
        return false unless File.exist? dir

        stat = File.stat dir 
      end

      group = Users::UserGroup.get(stat.gid - 10000)
      return false if group.nil?

      user.user_groups.include? group
    end
  end

end; end

