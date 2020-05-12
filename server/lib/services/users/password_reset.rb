require 'common'

require 'jobs/users/update_samba_job'
require 'jobs/users/update_radius_users_job'

module Sykus; module Users

  # Resets a the password of a user
  class PasswordReset < ServiceBase

    # @param [Integer] id User ID.
    # @return [Hash/String] Plaintext password.
    def action(id)
      id = id.to_i
      user = User.get(id)
      raise Exceptions::NotFound, 'User not found' if user.nil?

      if user.position_group == :student
        enforce_permission! :teacher_studentpwd
      else
        enforce_permission! :users_write
      end

      enforce_permission! :users_write_admin unless user.admin_group == :none

      if @identity.user_id == user.id
        raise Exceptions::Input, 'You cannot reset your own password'
      end

      password = GeneratePassword.run(user)

      user.password_initial = 
        ([ :student, :teacher ].include?(user.position_group) &&
         user.admin_group == :none) ? password : nil

      user.password_expired = true
      user.password_sha256 = Digest::SHA256.hexdigest(password)

      # fake nt password, create real after user has changed password himself
      user.password_nt = NTHash.get(SecureRandom.hex 32)

      validate_entity! user
      user.save

      Resque.enqueue UpdateRADIUSUsersJob
      Resque.enqueue UpdateSambaJob, user.username

      return { password: password }
    end
  end

end; end

