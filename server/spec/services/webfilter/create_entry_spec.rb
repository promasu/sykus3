require 'spec_helper'

require 'services/webfilter/create_entry'
require 'jobs/webfilter/build_db_job'

module Sykus

  describe Webfilter::CreateEntry do
    let (:create_entry) {
      Webfilter::CreateEntry.new IdentityTestGod.new 
    }

    let (:examplecom) {{
      domain: 'example.com',
      comment: 'comment',
      type: 'black_all',
    }}

    subject { create_entry.run examplecom }

    it 'works with all required parameters' do
      result = subject 

      id = result[:id]
      id.should be_a Integer

      entry = Webfilter::Entry.get id
      entry.domain.should == 'example.com'
      entry.comment.should == 'comment'
      entry.type.should == :black_all

      check_entity_evt(EntitySet.new(Webfilter::Entry), id, false)

      Resque.dequeue(Webfilter::BuildDBJob).should == 1
    end

    context 'with all types' do
      [ 
        :white_all, :nonstudents_only, :black_all 
      ].each do |type|
        it "works with type #{type}" do
          examplecom[:type] = type.to_s
          subject[:id].should be_a Integer
        end
      end
    end

    context 'errors' do
      it '#run raises on permission violation' do
        check_service_permission(:webfilter_write, Webfilter::CreateEntry, 
                                 :run, {})
      end

      it 'raises on duplicate entry' do
        create_entry.run examplecom

        expect { subject }.to raise_error Exceptions::Input
      end
    end
  end

end

