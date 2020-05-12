module Sykus; module Users

  # Checks if a username is a currently used unix system user.
  module CheckSystemUser

    # Raises if username is a system user.
    # @param [String] username Username.
    def self.enforce!(username)
      if system_users.include? username.downcase.strip
        raise Exceptions::Input, 'Username is system user!'
      end
    end

    private
    def self.system_users
      return @system_users if @system_users

      @system_users = %w{sykusadmin localuser}
      @system_users += File.read('/etc/passwd').split("\n").map do |line|
        line.split(':').first.strip.downcase
      end
    end
  end

end; end

