require 'spec_helper'

require 'jobs/common/demodata_job'

require 'api/main'

module Sykus

  describe 'DemoDataJob API' do
    def app; Sykus::Api::App; end

    context 'POST /demodata/ in demo mode' do
      before :each do
        Config::ConfigValue.set('demo', true)
      end

      it 'queues job' do
        Sykus::Api::App.any_instance.should_receive(:system)

        post '/demodata/'

        last_response.should be_ok
      end
    end

    context 'POST /demodata/ not in demo mode' do
      it 'raises' do
        Sykus::Api::App.any_instance.stub(:system).and_raise Exception

        post '/demodata/'

        last_response.status.should == 400
      end
    end
  end

end

