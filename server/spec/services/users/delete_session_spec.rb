require 'spec_helper'

require 'services/users/delete_session'
require 'jobs/webfilter/update_nonstudents_list_job'

module Sykus

  describe Users::DeleteSession do
    let (:delete_session) {
      Users::DeleteSession.new IdentityTestGod.new
    }
    let (:session) { Factory Users::Session } 

    it 'deletes a session' do
      delete_session.run session.id

      Users::Session.get(session.id).should be_nil 
      Resque.dequeue(Webfilter::UpdateNonStudentsListJob).should == 1
    end

    it 'does not fail on invalid session' do
      delete_session.run 'b' * 64
    end
  end

end

