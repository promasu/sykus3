require 'common'

module Sykus; module Users

  # Updates RADIUS user DB file.
  class UpdateRADIUSUsersJob
    extend Resque::Plugins::Queue::Lock
    extend Resque::Plugins::Workers::Lock
    @queue = :fast

    # Users file.
    USERS_FILE = '/etc/freeradius/users'

    # Runs the job.
    def self.perform
      old_conf = File.read USERS_FILE if File.exists? USERS_FILE
 
      # client image gets own user to connect to wifi
      # this user has a special character (.) so it cannot be taken already
      new_conf = "sykus.client NT-Password := \"#{get_client_hash}\"\n"

      Users::User.all(password_expired: false).each do |user|
        new_conf << "#{user.username} NT-Password := \"#{user.password_nt}\"\n"
      end

      return if old_conf == new_conf

      File.open(USERS_FILE, 'w+') { |f| f.write new_conf }
      system 'sudo /etc/init.d/freeradius reload'
    end

    private
    def self.get_client_hash
      password = Config::ConfigValue.get('radius_client_password')

      if password.nil?
        password = SecureRandom.hex 16
        Config::ConfigValue.set('radius_client_password', password)
      end

      NTHash.get password
    end
  end

end; end

