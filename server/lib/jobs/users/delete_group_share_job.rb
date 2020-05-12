require 'common'

module Sykus; module Users

  # Deletes a group share folder.
  class DeleteGroupShareJob
    extend Resque::Plugins::Lock
    @queue = :slow

    # Group directory base.
    GROUP_DIR = '/home/groups'

    # Runs the job.
    def self.perform(id)
      system "sudo rm -rf #{GROUP_DIR}/.g#{id.to_i}"
    end
  end

end; end

