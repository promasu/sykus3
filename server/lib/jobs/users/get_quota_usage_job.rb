require 'common'

require 'jobs/common/get_disk_space_job'

module Sykus; module Users

  # Gets disk space currently used by each user.
  class GetQuotaUsageJob
    extend Resque::Plugins::Lock
    @queue = :slow

    # Runs the job.
    def self.perform
      GetDiskSpaceJob.perform

      %x{sudo repquota -anu}.split("\n").each do |line|
        next unless line[0] == '#'
        uid, _dummy, blocks_used = line.split(' ')

        uid = uid[1..-1].to_i - 10000
        space_used = blocks_used.to_i * QuotaConfig::BLOCK_SIZE / 1024.0**2
        space_used = space_used.ceil

        next if uid < 1  # linux system user
        user = User.get(uid)
        next if user.nil?

        if user.quota_used_mb != space_used
          user.quota_used_mb = space_used
          user.save

          entity_evt = EntityEvent.new(EntitySet.new(User), user.id, false)
          EntityEventStore.save entity_evt
        end
      end
    end
  end

end; end

