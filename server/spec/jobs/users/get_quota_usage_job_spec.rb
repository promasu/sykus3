require 'spec_helper'

require 'jobs/users/get_quota_usage_job'
require 'jobs/common/get_disk_space_job'

module Sykus

  describe Users::GetQuotaUsageJob do
    let! (:u1) { Factory Users::User }
    let! (:u2) { Factory Users::User }

    def quota_line(uid, space_used_mb)
      blocks = space_used_mb * 1024 * 1024 / Users::QuotaConfig::BLOCK_SIZE
      "##{uid + 10000}  --  #{blocks} 0 0 #{blocks / 2} 0 0\n"
    end

    it 'sets correct quotas' do
      job = Users::GetQuotaUsageJob

      GetDiskSpaceJob.should_receive(:perform)

      data = "Report xxx\nBlock grace: xxx\n---\n"
      data << quota_line(u1.id, 321)
      data << quota_line(u2.id, 420)
      data << quota_line(500, 300)

      job.should_receive(:`).with('sudo repquota -anu').and_return(data)

      job.perform

      u1.reload.quota_used_mb.should == 321
      u2.reload.quota_used_mb.should == 420
      check_entity_evt(EntitySet.new(Users::User), u1.id, false)
      check_entity_evt(EntitySet.new(Users::User), u2.id, false)
    end
  end

end

