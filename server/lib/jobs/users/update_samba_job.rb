require 'common'

module Sykus; module Users

  # Updates the samba passdb entry for a user.
  class UpdateSambaJob
    extend Resque::Plugins::Lock
    @queue = :fast

    # Runs the job.
    # We cannot use User ID because pdbedit does not support deleting by id.
    # @param [String] username User username.
    def self.perform(username)
      user = User.first(username: username)

      if user.nil?
        system "sudo pdbedit -u #{username} -x"
        return
      end

      # Wait until user has a valid NSS entry.
      # pdbedit fails if there is no valid username:id pair in NSS.
      Timeout::timeout(5) do
        loop do
          begin
            passwd = Etc.getpwnam user.username
          rescue ArgumentError
          end

          break if passwd && passwd.uid == user.system_id
          sleep 0.5
        end
      end

      lm = 'X' * 32
      nt = user.password_nt.upcase

      fl = '[UX         ]'  # must be 13 chars (including brackets)
      cr = 'LCT-00000000'   # creation time with hex timestamp

      f = Tempfile.new 'smb'
      f.write "#{user.username}:#{user.system_id}:#{lm}:#{nt}:#{fl}:#{cr}:"
      f.close

      system "sudo pdbedit -i smbpasswd:#{f.path}"
      f.unlink
    end
  end

end; end

