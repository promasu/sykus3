require 'common'

module Sykus; module Users

  # Creates new NSS DB files for users and groups.
  class CreateNSSDBJob
    extend Resque::Plugins::Queue::Lock
    extend Resque::Plugins::Workers::Lock
    @queue = :fast

    # DB target directory.
    DB_DIR = '/var/lib/sykus3/nssdb'

    # User home root directory.
    HOME_DIR = '/home/users'

    # Runs the job.
    def self.perform
      users_server = Tempfile.new 'u'
      users_client = Tempfile.new 'u'
      groups = Tempfile.new 'g'

      group_share_teacher = []
      group_share_admin = []
      group_share_progdata = []

      i = 0
      User.all.each do |user|
        permissions = UserPermissions.get user

        # group association
        if permissions.include? :share_teacher_access
          group_share_teacher << user.username
        end

        if permissions.include? :share_admin_access
          group_share_admin << user.username
        end

        if permissions.include? :share_progdata_write
          group_share_progdata << user.username
        end

        # create user entry
        entry_server = "#{user.username}:x:#{user.system_id}:100::" +
        "#{HOME_DIR}/u#{user.id}:/bin/false"
        entry_client = "#{user.username}:x:#{user.system_id}:100:" +
        "#{user.full_name.to_s}:/home/#{user.username}:/bin/bash"

        [
          [ users_server, entry_server ],
          [ users_client, entry_client ]
        ].each do |args|
          file, entry = *args
          file.write "0#{i} #{entry}\n"
          file.write "=#{user.system_id} #{entry}\n"
          file.write ".#{user.username} #{entry}\n"
        end
        i += 1
      end

      user_groups = UserGroup.all.map do |group|
        members = group.users.map { |u| u.username }
        [ "sykus-group-#{group.id}", group.system_id, members ]
      end

      # make sure GIDs are in sync with shares::default recipe
      i = 0
      ([
       [ 'sykus-share-progdata', 42001, group_share_progdata ],
       [ 'sykus-share-teacher', 42002, group_share_teacher ],
       [ 'sykus-share-admin', 42003, group_share_admin ],
      ] + user_groups).each do |e|
        name, gid, list = *e

        list.unshift 'sykus3' if gid > 42000

        entry = "#{name}:x:#{gid}:#{list.join(',')}"

        groups.write "0#{i} #{entry}\n"
        groups.write "=#{gid} #{entry}\n"
        groups.write ".#{name} #{entry}\n"
        i += 1
      end

      users_server.close
      users_client.close
      groups.close

      system "makedb #{users_server.path} #{DB_DIR}/users_server.db" 
      system "makedb #{users_client.path} #{DB_DIR}/users_client.db" 
      system "makedb #{groups.path} #{DB_DIR}/groups.db" 
      Dir["#{DB_DIR}/*.db"].each { |f| File.chmod 0644, f }

      users_server.unlink
      users_client.unlink
      groups.unlink
    end
  end

end; end

