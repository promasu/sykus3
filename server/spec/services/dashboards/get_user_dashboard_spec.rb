require 'spec_helper'

require 'services/dashboards/get_user_dashboard'

module Sykus

  describe Dashboards::GetUserDashboard do
    let (:identity) { IdentityTestGod.new } 
    let (:get_user_dashboard) { Dashboards::GetUserDashboard.new identity }
    let! (:user) { Factory Users::User, quota_used_mb: 3 }

    before :each do
      identity.user_id = user.id
    end

    it 'returns correct values' do
      res = get_user_dashboard.run
      res[:quota_used].should == 3
      res[:quota_total].should == Users::GetUserMaxQuota.get(user)
    end

    context 'errors' do
      it 'raises on invalid user' do
        user.destroy

        expect {
          get_user_dashboard.run
        }.to raise_error Exceptions::Input
      end
    end

  end

end

