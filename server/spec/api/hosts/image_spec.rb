require 'spec_helper'

require 'services/hosts/create_image'
require 'jobs/hosts/create_image_job'
require 'jobs/hosts/abort_image_job'

require 'api/main'

module Sykus

  describe 'Hosts::Image API' do
    def app; Sykus::Api::App; end

    let (:identity) { IdentityTestGod.new } 
    let (:create_image) { Hosts::CreateImage.new identity }

    context 'GET /image' do
      it 'returns image status' do
        get '/image'

        last_response.should be_ok
        last_response.body.should == (:idle).to_json
      end
    end

    context 'POST /image' do
      it 'creates image job (later)' do
        post '/image', { now: false }.to_json

        last_response.status.should == 204
        Resque.dequeue(Hosts::CreateImageJob, false).should == 1
      end

      it 'creates image job (now)' do
        post '/image', { now: true }.to_json

        last_response.status.should == 204
        Resque.dequeue(Hosts::CreateImageJob, true).should == 1
      end
    end

    context 'DELETE /image' do
      it 'aborts image' do
        delete '/image'

        last_response.status.should == 204
        Resque.dequeue(Hosts::AbortImageJob).should == 1
      end
    end
  end

end

