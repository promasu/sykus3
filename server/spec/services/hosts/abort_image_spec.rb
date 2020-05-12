require 'spec_helper'

require 'services/hosts/abort_image'

module Sykus

  describe Hosts::AbortImage do
    let (:identity) { IdentityTestGod.new } 
    let (:abort_image) { Hosts::AbortImage.new identity } 

    it 'aborts image' do
      abort_image.run
      Resque.dequeue(Hosts::AbortImageJob).should == 1 
    end

    context 'errors' do
      it '#run raises on permission violation' do
        check_service_permission(:image_create, Hosts::AbortImage, :run)
      end
    end
  end

end

