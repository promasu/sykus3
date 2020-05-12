require 'spec_helper'

require 'jobs/common/get_disk_space_job'

module Sykus

  describe GetDiskSpaceJob do
    it 'stores valid values' do
      GetDiskSpaceJob.perform

      free = REDIS.get('diskspace.home.free').to_i
      total = REDIS.get('diskspace.home.total').to_i

      # we cannot stub out Sys::Filesystem calls,
      # so just do some basic validation of real system data
      free.should > 1024
      total.should > 5 * 1024
      total.should > free
      end
    end

  end

