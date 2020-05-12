require 'common'

require 'jobs/webfilter/update_nonstudents_list_job'

module Sykus; module Users

  # Creates a new user session (aka. logging in).
  class CreateSession < ServiceBase

    # @param [Hash] args Hash with login arguments.
    # @param [Boolean] salted_hash_password Password is salted?
    # @param [Hash] ip Remote IP.
    # @return [Hash/String] Session ID.
    def run(args, salted_hash_password = false, ip = nil)
      raise Exceptions::Input unless args[:username].is_a? String
      raise Exceptions::Input unless args[:password].is_a? String

      user = User.first username: args[:username] 
      raise Exceptions::NotFound, 'Invalid Login' if user.nil?

      if salted_hash_password
        if Digest::SHA256.hexdigest('SYKUSSALT' + user.password_sha256) != 
          args[:password]
          raise Exceptions::NotFound, 'Invalid Login' 
        end
      else
        if user.password_sha256 != Digest::SHA256.hexdigest(args[:password])
          raise Exceptions::NotFound, 'Invalid Login' 
        end
      end

      return { password_expired: true } if user.password_expired

      host_login = args[:host_login] && ip && 
        ip > IPAddr.new('10.42.100.0') && 
        ip < IPAddr.new('10.42.200.0')

      host = Hosts::Host.first ip: ip if host_login

      # destroy all session from other hosts if logged in from a 
      # known host to prevent multiple logins
      Session.all(user: user, :host.not => nil).destroy if host

      id = SecureRandom.hex 32
      session = Session.new id: id, user: user, ip: ip, host: host

      validate_entity! session
      session.save

      Logs::SessionLog.create username: user.username, ip: ip, 
        type: (host_login ? :host_login : :login)

      Resque.enqueue Webfilter::UpdateNonStudentsListJob

      { id: session.id }
    end
  end

end; end

