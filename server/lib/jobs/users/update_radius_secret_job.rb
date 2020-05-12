require 'common'

module Sykus; module Users

  # Updates RADIUS client secret file.
  class UpdateRADIUSSecretJob
    extend Resque::Plugins::Queue::Lock
    extend Resque::Plugins::Workers::Lock
    @queue = :fast

    # Client config file.
    CLIENTS_FILE = '/etc/freeradius/clients.conf'

    # Runs the job.
    def self.perform
      password = Config::ConfigValue.get('radius_secret')

      if password.nil?
        password = SecureRandom.hex 16
        Config::ConfigValue.set('radius_secret', password)
      end

      old_conf = File.read CLIENTS_FILE if File.exists? CLIENTS_FILE

      new_conf  = "client 10.42.0.0/16 {\n"
      new_conf << "secret = #{Shellwords.shellescape password}\n"
      new_conf << "}\n"

      return if old_conf == new_conf

      File.open(CLIENTS_FILE, 'w+') { |f| f.write new_conf }
      system 'sudo /etc/init.d/freeradius restart'
    end
  end

end; end

