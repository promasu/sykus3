require 'common'

require 'jobs/hosts/create_image_job'

module Sykus; module Hosts

  # Create a new image.
  class CreateImage < ServiceBase

    # @param [Hash] args Argument hash.
    def action(args)
      enforce_permission! :image_create

      Resque.enqueue CreateImageJob, !!args[:now]
      nil
    end

    # Returns the current state of image creation.
    # @return [Symbol] State.
    def state
      # no permission needed 

      Resque.workers.each do |w|
        next if w.job == {}
        if w.job['payload']['class'] == Hosts::CreateImageJob.name
          return w.job['payload']['args'].first ? :running : :scheduled
        end
      end

      return :idle
    end
  end

end; end

