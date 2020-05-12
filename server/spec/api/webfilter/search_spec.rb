require 'spec_helper'

require 'services/webfilter/search_categories'

require 'api/main'

module Sykus

  describe 'Webfilter::Category API' do
    def app; Sykus::Api::App; end

    let (:identity) { IdentityTestGod.new } 
    let (:search_categories) { Webfilter::SearchCategories.new identity }

    context 'POST /webfilter/search/' do
      it 'returns valid result' do
        # this is not clean but I cannot think of a nicer way
        # to stub the system call
        result = 'bundle/cat1/domains:example.com'
        Webfilter::SearchCategories.any_instance.
          should_receive(:`).and_return(result)

        args = { domain: 'example.com' }
        post '/webfilter/search/', args.to_json

        last_response.should be_ok
        last_response.body.should == { lists: [ 'bundle/cat1' ] }.to_json
      end
    end
  end

end

