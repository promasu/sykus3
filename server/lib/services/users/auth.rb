require 'common'


module Sykus; module Users

  # Authenticates a user and returns user details.
  class Auth < ServiceBase

    # @param [Hash] args Hash with login arguments.
    # @param [Hash] ip Remote IP.
    # @return [Hash] User data.
    def run(args, ip)
      raise Exceptions::Input unless args[:username].is_a? String
      raise Exceptions::Input unless args[:password].is_a? String

      user = User.first username: args[:username], password_expired: false,
        password_sha256: Digest::SHA256.hexdigest(args[:password]) 
      raise Exceptions::NotFound, 'Invalid Login' if user.nil?

      Logs::SessionLog.create username: user.username, ip: ip, 
        type: :auth

      { 
        id: user.id,
        username: user.username,
        first_name: user.full_name.first_name,
        last_name: user.full_name.last_name,
        birthdate: user.birthdate,
        position_group: user.position_group.to_s,
        admin_group: user.admin_group.to_s,
      }
    end
  end

end; end

