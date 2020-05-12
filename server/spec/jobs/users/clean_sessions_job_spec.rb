require 'spec_helper'

require 'jobs/users/clean_sessions_job'
require 'jobs/webfilter/update_nonstudents_list_job'

module Sykus

  describe Users::CleanSessionsJob do
    let! (:session_old) { Factory Users::Session, updated_at: Time.now - 60 }
    let! (:session_new) { Factory Users::Session, updated_at: Time.now - 5 }

    it 'deletes old sessions' do
      Users::CleanSessionsJob.perform

      Users::Session.get(session_old.id).should be_nil
      Users::Session.get(session_new.id).should_not be_nil
      Resque.dequeue(Webfilter::UpdateNonStudentsListJob).should == 1
    end

    it 'does nothing if there are no old sessions' do
      session_old.destroy

      Users::CleanSessionsJob.perform

      Users::Session.get(session_new.id).should_not be_nil
      Resque.dequeue(Webfilter::UpdateNonStudentsListJob).should == 0
    end

  end

end

