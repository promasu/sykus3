require 'spec_helper'

require 'jobs/users/update_homedir_job'

module Sykus

  describe Users::UpdateHomedirJob do
    let (:job) { Users::UpdateHomedirJob }
    let (:user) { Factory Users::User, id: 1, username: 'user1' } 
    let (:dir) { "/home/users/u#{user.id}" }

    it 'creates/updates a homedir correctly' do

      job.should_receive('system').with "sudo mkdir -p #{dir}"
      job.should_receive('system').with \
        "sudo chown -R #{user.system_id}:sykus3 #{dir}"
      job.should_receive('system').with "sudo chmod -R 0770 #{dir}" 

      job.perform user.id
    end

    it 'deletes a homedir correctly' do
      job.should_receive('system').with 'sudo rm -rf /home/users/u42'

      job.perform 42
    end
  end

end

