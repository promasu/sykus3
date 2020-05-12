require 'spec_helper'

require 'jobs/users/update_group_shares_job'

module Sykus

  describe Users::UpdateGroupSharesJob do
    let (:job) { Users::UpdateGroupSharesJob }
    let! (:owner) { 
      Factory Users::User, full_name: Users::FullUserName.new('John', 'Doe') 
    }
    let! (:group) { 
      Factory Users::UserGroup, id: 1, name: 'name 12', owner: owner
    } 

    it 'creates/updates group dirs and symlinks correctly' do
      [
        'touch /home/groups/.touchfile',

        'mkdir -p /home/groups/.g1',
        'touch /home/groups/.g1',
        'chmod 2770 /home/groups/.g1',
        'chown sykus3:10001 /home/groups/.g1',
        'ln -sf .g1 /home/groups/name\ 12\ -\ John\ Doe\ \(1\)',
        'touch -h /home/groups/name\ 12\ -\ John\ Doe\ \(1\)',
        'chown -h sykus3:10001 /home/groups/name\ 12\ -\ John\ Doe\ \(1\)',

        'find /home/groups -type l -mindepth 1 -maxdepth 1 ! ' + 
        '-newer /home/groups/.touchfile -exec rm -f {} \;'
      ].each do |line|
        job.should_receive('system').with "sudo #{line}"
      end


      job.perform 
    end

  end

end

