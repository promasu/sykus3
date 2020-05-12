module Sykus; module Users

  # Returns quota limit based on user data.
  module GetUserMaxQuota

    # @param [User] user User Object.
    # @return [Integer] Maximum quota in MB.
    def self.get(user)
      raise Exceptions::Input, 'Invalid user' unless user.is_a? Users::User

      quota_total_key = 
        if [ :senior, :super ].include? user.admin_group
          'diskspace.quota.admin'
        elsif user.position_group == :student
          'diskspace.quota.student'
        else
          'diskspace.quota.teacher'
        end

      (REDIS.get(quota_total_key) || 420).to_i
    end
  end

end; end

