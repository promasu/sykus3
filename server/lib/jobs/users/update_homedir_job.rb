require 'common'

module Sykus; module Users

  # Updates or creates the user home directory.
  class UpdateHomedirJob
    extend Resque::Plugins::Lock
    @queue = :slow

    # Home directory base.
    HOME_DIR = '/home/users'

    # Runs the job.
    # @param [Integer] id User ID.
    def self.perform(id)
      raise unless id.is_a? Integer

      home_dir = "#{HOME_DIR}/u#{id}"
      user = User.get(id)
      if user.nil?
        system "sudo rm -rf #{home_dir}"
        return
      end

      system "sudo mkdir -p #{home_dir}"
      system "sudo chown -R #{user.system_id}:sykus3 #{home_dir}"
      system "sudo chmod -R 0770 #{home_dir}"
    end
  end

end; end

