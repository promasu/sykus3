require 'spec_helper'

require 'services/webfilter/search_categories'

module Sykus

  describe Webfilter::SearchCategories do
    let (:search_categories) { 
      Webfilter::SearchCategories.new IdentityTestGod.new
    }
    let (:dir) { Webfilter::SearchCategories::LIST_DIRECTORY }

    context 'permission violations' do
      it 'raises on #run' do
        check_service_permission(:webfilter_read, 
                                 Webfilter::SearchCategories, :run, {})
      end
    end

    context 'finds categories by domain name' do
      it 'finds correct categories' do
        cmd = "grep -r ^example\.com$ #{dir}/*"
        response = "#{dir}/bundle/cat1/domains:example.com\n" +
          "#{dir}/bundle:example.com\n" +
          "#{dir}/bundle/cat2/domains:example.com\n"

        search_categories.should_receive(:`).with(cmd).and_return(response)
        res = search_categories.run domain: 'example.com'

        res[:lists].should =~ [ 'bundle/cat1', 'bundle/cat2' ]
      end

      it 'works with www. prefix' do
        cmd = "grep -r ^example\.com$ #{dir}/*"
        search_categories.should_receive(:`).with(cmd).and_return('')
        search_categories.run domain: 'www.example.com'
      end

      it 'works with www. in domain name' do
        cmd = "grep -r ^exwww\.com$ #{dir}/*"
        search_categories.should_receive(:`).with(cmd).and_return('')
        search_categories.run domain: 'exwww.com'
      end


      it 'works with /path suffix and double // in path' do
        cmd = "grep -r ^example\.com$ #{dir}/*"
        search_categories.should_receive(:`).with(cmd).and_return('')
        search_categories.run domain: 'example.com//test/page/'
      end


      it 'works with proto:// prefix' do
        cmd = "grep -r ^example\.com$ #{dir}/*"
        search_categories.should_receive(:`).with(cmd).and_return('')
        search_categories.run domain: 'http://example.com'
      end

      it 'works all fixes' do
        cmd = "grep -r ^sub\.example\.com$ #{dir}/*"
        search_categories.should_receive(:`).with(cmd).and_return('')
        search_categories.run domain: 'https://www.sub.example.com/bla'
      end


      it 'raises on invalid input' do
        expect {
          # make sure length check if run after prefix/suffix fixes
          search_categories.run domain: 'http://a'
        }.to raise_error Exceptions::Input
      end
    end
  end

end

