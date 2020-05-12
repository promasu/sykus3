require 'common'

module Sykus; module Dashboards

  # Gets user dashboard data.
  class GetUserDashboard < ServiceBase

    # @return [Hash] Dashboard data.
    def run
      user = Users::User.get @identity.user_id 
      raise Exceptions::Input, 'Invalid user' if user.nil?

      {
        quota_used: user.quota_used_mb,
        quota_total: Users::GetUserMaxQuota.get(user),
      }
    end
  end

end; end

