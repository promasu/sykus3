require 'common'

require 'jobs/users/update_samba_job'
require 'jobs/users/update_radius_users_job'

module Sykus; module Users

  # Sets a new password for the given user.
  class ChangePassword < ServiceBase

    # @param [Hash] args Argument hash.
    # @param [IPAddr] ip Remote IP.
    def run(args, ip)
      raise Exceptions::Input unless args[:username].is_a? String
      raise Exceptions::Input unless args[:old_password].is_a? String
      raise Exceptions::Input unless args[:new_password].is_a? String

      user = Users::User.first(username: args[:username])

      old_hash = Digest::SHA256.hexdigest args[:old_password]
      if user.nil? || user.password_sha256 != old_hash
        raise Exceptions::NotFound, 'Invalid login.' if user.nil?
      end

      if args[:new_password].length < 8
        raise Exceptions::Input, 'New password too short (min. 8 chars).'
      end

      if user.password_expired
        if ip < IPAddr.new('10.42.1.1') || ip >= IPAddr.new('10.42.255.255')
          raise Exceptions::Input, 
            'Must change expired password within local network.'
        end
      end

      user.password_expired = false
      user.password_initial = nil
      user.password_sha256 = Digest::SHA256.hexdigest args[:new_password]
      user.password_nt = NTHash.get args[:new_password]

      validate_entity! user
      user.save

      Resque.enqueue UpdateRADIUSUsersJob
      Resque.enqueue UpdateSambaJob, user.username

      nil
    end
  end

end; end

