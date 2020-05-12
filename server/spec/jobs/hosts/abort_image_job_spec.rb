require 'spec_helper'

require 'jobs/hosts/abort_image_job'
require 'jobs/hosts/create_image_job'

module Sykus

  describe Hosts::AbortImageJob do
    it 'aborts image creation' do
      job = Hosts::AbortImageJob
      job.should_receive(:system).with \
        'sudo stop sykus3-worker-image; sudo start sykus3-worker-image'
      job.should_receive(:system).with 'virsh destroy sykuscli'

      Resque.enqueue Hosts::CreateImageJob, false
      Resque.enqueue Hosts::CreateImageJob, true

      job.perform

      Resque.dequeue(Hosts::CreateImageJob, false).should == 0
      Resque.dequeue(Hosts::CreateImageJob, true).should == 0
    end
  end

end


