require 'common'

require 'jobs/hosts/abort_image_job'

module Sykus; module Hosts

  # Aborts image creation.
  class AbortImage < ServiceBase

    # No params.
    def action
      enforce_permission! :image_create

      Resque.enqueue AbortImageJob
      nil
    end
  end

end; end

