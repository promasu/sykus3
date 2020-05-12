require 'spec_helper'

require 'jobs/users/delete_group_share_job'

module Sykus

  describe Users::DeleteGroupShareJob do
    let (:job) { Users::DeleteGroupShareJob }
    let! (:owner) { Factory Users::User }
    let! (:group) { 
      Factory Users::UserGroup, id: 1, name: 'name 12', owner: owner
    } 

    it 'deletes group dir correctly' do
      job.should_receive('system').with "sudo rm -rf /home/groups/.g1"
      job.perform group.id
    end

  end

end

