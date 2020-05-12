require 'spec_helper'

require 'services/hosts/create_image'

module Sykus

  describe Hosts::CreateImage do
    let (:identity) { IdentityTestGod.new } 
    let (:create_image) { Hosts::CreateImage.new identity } 

    def fake_process_one_job
      worker = Resque::Worker.new(:image)
      worker.register_worker
      job = worker.reserve
      worker.working_on job if job
    end

    it 'schedules job for now' do
      create_image.run({ now: true })

      Resque.dequeue(Hosts::CreateImageJob, false).should == 0
      Resque.dequeue(Hosts::CreateImageJob, true).should == 1
    end

    it 'schedules job for later' do
      create_image.run({ now: false })

      Resque.dequeue(Hosts::CreateImageJob, false).should == 1
      Resque.dequeue(Hosts::CreateImageJob, true).should == 0
    end

    it 'returns correct state when idle (with worker present)' do
      fake_process_one_job 

      create_image.state.should == :idle
    end

    it 'returns correct state when idle' do
      create_image.state.should == :idle
    end

    it 'returns correct state when running' do
      Resque.enqueue Hosts::CreateImageJob, true
      fake_process_one_job

      create_image.state.should == :running
    end

    it 'returns correct state when scheduled' do
      Resque.enqueue Hosts::CreateImageJob, false
      fake_process_one_job

      create_image.state.should == :scheduled
    end

    context 'errors' do
      it '#run raises on permission violation' do
        check_service_permission(:image_create, Hosts::CreateImage, :run, {})
      end
    end

    end

end

