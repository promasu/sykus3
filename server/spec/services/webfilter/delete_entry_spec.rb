require 'spec_helper'

require 'services/webfilter/delete_entry'
require 'jobs/webfilter/build_db_job'

module Sykus

  describe Webfilter::DeleteEntry do
    let (:identity) { IdentityTestGod.new } 
    let (:delete_entry) { Webfilter::DeleteEntry.new identity }

    let (:entry) { Factory Webfilter::Entry }
    let (:uid) { entry.id }

    context 'input parameters' do
      it 'works with entry id' do
        delete_entry.run uid

        Webfilter::Entry.get(uid).should be_nil
        check_entity_evt(EntitySet.new(Webfilter::Entry), uid, true)

        Resque.dequeue(Webfilter::BuildDBJob).should == 1
      end
    end

    context 'errors' do
      it 'raises on permission violation' do
        check_service_permission(:webfilter_write, Webfilter::DeleteEntry, 
                                 :run, 1)
      end

      it 'raises on invalid id' do
        expect {
          delete_entry.run 4200
        }.to raise_error Exceptions::NotFound
      end
    end
  end

end

