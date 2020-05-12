require 'common'

require 'jobs/hosts/create_image_job'

module Sykus; module Hosts

  # Aborts the image by restarting resque worker.
  class AbortImageJob
    extend Resque::Plugins::Lock
    @queue = :fast

    # Runs the job.
    def self.perform
      Resque.dequeue CreateImageJob

      # no cleanup, but shut off VM for performance reasons
      system 'sudo stop sykus3-worker-image; sudo start sykus3-worker-image'
      system 'virsh destroy sykuscli'
    end
  end

end; end

