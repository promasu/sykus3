require 'spec_helper'

require 'jobs/users/update_quotas_job'
require 'jobs/common/get_disk_space_job'

module Sykus

  describe Users::UpdateQuotasJob do
    let (:calc_result) {{
      student: 300,
      teacher: 900,
      admin: 10000,
    }}

    let! (:student) {
      Factory Users::User, quota_used_mb: 390, position_group: :student
    }
    let! (:teacher) {
      Factory Users::User, position_group: :teacher, admin_group: :junior
    }
    let! (:admin) {
      Factory Users::User, position_group: :student, admin_group: :super
    }

    def quota_line(user, quota_mb)
      b = quota_mb * 1024 * 1024 / Users::QuotaConfig::BLOCK_SIZE
      "#{user.system_id} #{b} #{b} #{b} #{b}\n"
    end

    it 'sets correct quotas' do
      job = Users::UpdateQuotasJob

      GetDiskSpaceJob.should_receive(:perform)
      Users::CalculateQuotas.should_receive(:get).once.and_return(calc_result)

      job.should_receive(:system) do |line|
        cmd, file = line.split('<')
        cmd.strip.should == 'sudo setquota -abcu'

        ref = quota_line(student, 500)  # overallocation test
        ref << quota_line(teacher, calc_result[:teacher])
        ref << quota_line(admin, calc_result[:admin])

        File.read(file.strip).strip.should == ref.strip
      end

      job.perform

      calc_result.each do |group, value|
        REDIS.get("diskspace.quota.#{group}").to_i.should == value
      end
    end
  end

end

