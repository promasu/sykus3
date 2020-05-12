require 'common'

require 'jobs/common/get_disk_space_job'

module Sykus; module Users

  # Updates user quotas with their individual value.
  class UpdateQuotasJob
    extend Resque::Plugins::Lock
    @queue = :slow

    # Runs the job.
    def self.perform
      GetDiskSpaceJob.perform

      user_count = User.count
      free_space = REDIS.get('diskspace.home.free').to_i
      total_space = REDIS.get('diskspace.home.total').to_i

      calc = CalculateQuotas.get(user_count, free_space, total_space)
      calc.each do |group, value|
        REDIS.set "diskspace.quota.#{group}", value
      end

      file = Tempfile.new 'quotas'
      User.all.each do |user|
        quota = (user.position_group == :student) ? 
          calc[:student] : calc[:teacher]
        quota = calc[:admin] if [ :senior, :super ].include? user.admin_group

        while user.quota_used_mb > (quota - QuotaConfig::MIN_FREE_SPACE)
          quota += QuotaConfig::QUOTA_STEP
        end

        blk = ino = quota * 1024 * 1024 / QuotaConfig::BLOCK_SIZE
        file.write "#{user.system_id} #{blk} #{blk} #{ino} #{ino}\n"
      end
      file.close

      system "sudo setquota -abcu < #{file.path}"
      file.unlink
    end
  end

end; end

