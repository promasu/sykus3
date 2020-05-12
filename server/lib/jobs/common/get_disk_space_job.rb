require 'common'

module Sykus

  # Get free and total disk space and store in Redis.
  class GetDiskSpaceJob
    extend Resque::Plugins::Lock
    @queue = :fast

    # Runs the job.
    def self.perform
      stat = Sys::Filesystem.stat '/home'

      # store values in MB
      factor = stat.block_size / (1024.0 * 1024.0)

      free = (stat.blocks_available * factor).to_i
      total = (stat.blocks * factor).to_i

      REDIS.set 'diskspace.home.free', free
      REDIS.set 'diskspace.home.total', total
    end
  end

end

