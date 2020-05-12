require 'common'


module Sykus; module Users

  # Finds the correct username for a given full name.
  class FindUsername < ServiceBase

    # @param [Hash] args Hash of `first_name` and `last_name`
    # @return [Hash/String] Proposed Username.
    def run(args)
      enforce_permission! :users_read

      begin
        full_name = FullUserName.new(args[:first_name], args[:last_name])
        username = GenerateUsername.run full_name, args[:ref_id].to_i
      rescue Exceptions::Input
        username = false
      end
      { username: username }
    end
  end

end; end
