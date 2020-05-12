require 'common'

module Sykus; module Files

  # Get a file path or directory information.
  class GetFile < ServiceBase

    # @param [String] path Directory path.
    # @return [Array] Array of directory entries.
    def get_dir(path)
      return get_group_dir if path == 'groups'

      path = get_real_path path    
      raise Exceptions::Input, 'Not a directory' unless File.directory? path 

      Dir.entries(path).map do |entry|
        # match '.', '..' and hidden files
        next if entry.match(/^\./)

        full_entry = File.join(path, entry)
        next if File.symlink? full_entry

        stat = File.lstat full_entry

        # hide desktop starters (aka. shortcuts)
        next if !stat.directory? && entry.match(/\.desktop$/)

        {
          name: entry,
          dir: stat.directory?,
          size: stat.directory? ? 0 : stat.size,
          mtime: stat.mtime.to_i,
        }
      end.compact.sort do |a, b| 
        result = (a[:dir] ? 0:1) <=> (b[:dir] ? 0:1)
        next result unless result.zero?
        a[:name].downcase <=> b[:name].downcase
      end  
    end

    # @param [String] path File path.
    # @return [String] Full server side path (gets fed into sinatra-sendfile)
    def get_file(path)
      path = get_real_path path
      raise Exceptions::Input, 'Not a regular file' unless File.file? path

      path
    end

    private
    def get_group_dir
      get_group_maps.keys.map do |name|
        {
          name: name,
          dir: true,
          size: 0,
          mtime: 0,
        }
      end
    end

    def get_group_maps
      user_groups = {}

      user = Users::User.get(@identity.user_id)
      raise Exceptions::NotFound, 'User not found' if user.nil?

      user.user_groups.each do |ug|
        key = "#{ug.name} - #{ug.owner.full_name} (#{ug.id})"
          user_groups[key] = ".g#{ug.id}"
      end
      user_groups
    end

    def get_real_path(path)
      path = File.expand_path(path, '/')
      dirs = path.split('/')

      base_path = 
        case dirs[1]
        when 'home'
          "/home/users/u#{@identity.user_id.to_i}"
        when 'admin'
          enforce_permission! :share_admin_access
          '/home/share/admin'
        when 'teacher'
          enforce_permission! :share_teacher_access
          '/home/share/teacher'
        when 'progdata'
          '/home/share/progdata'
        when 'groups'
          '/home/groups'
        else
          raise Exceptions::Input, 'Invalid basedir'
        end

      if dirs[1] == 'groups' && dirs[2]
        dirs[2] = get_group_maps[dirs[2]]
        raise Exceptions::NotFound, 'Invalid group' if dirs[2].nil?
      end

      path = File.join(base_path, File.join(*dirs[2..-1]))
      raise Exceptions::NotFound, 'Path not found' unless File.exists? path 

      path
    end
  end

end; end

