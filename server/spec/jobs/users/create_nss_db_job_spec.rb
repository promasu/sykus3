require 'spec_helper'

require 'jobs/users/create_nss_db_job'

module Sykus

  describe Users::CreateNSSDBJob do
    include FakeFS::SpecHelpers
    before { FileUtils.mkdir_p '/tmp' }

    let! (:u1) {
      Factory Users::User, id: 1, username: 'user1', 
      full_name: Users::FullUserName.new('First', 'Last'),
      position_group: :teacher, admin_group: :junior
    }
    let! (:u2) {
      Factory Users::User, id: 2, username: 'user2', 
      full_name: Users::FullUserName.new('First', 'Last'),
      position_group: :student, admin_group: :senior
    }

    let! (:g1) {
      Factory Users::UserGroup, id: 1, owner: u1, users: [ u1, u2 ]
    }

    let (:job) { Users::CreateNSSDBJob }

    it 'generates correct database files' do
      job.should_receive(:system).exactly(3).times do |arg|
        cmd, infile, outfile = arg.split(' ')
        cmd.should == 'makedb'

        case File.basename outfile
        when 'users_server.db'
          line1 = 'user1:x:10001:100::/home/users/u1:/bin/false'
          line2 = 'user2:x:10002:100::/home/users/u2:/bin/false'
        when 'users_client.db'
          line1 = 'user1:x:10001:100:First Last:/home/user1:/bin/bash'
          line2 = 'user2:x:10002:100:First Last:/home/user2:/bin/bash'
        when 'groups.db'
          line1 = 'sykus-share-progdata:x:42001:sykus3,user1,user2'
          line2 = 'sykus-share-teacher:x:42002:sykus3,user1'
          line3 = 'sykus-share-admin:x:42003:sykus3,user1,user2'
          line4 = 'sykus-group-1:x:10001:user1,user2'

          File.read(infile).strip.should == 
            "00 #{line1}\n=42001 #{line1}\n.sykus-share-progdata #{line1}" + 
            "\n" +
            "01 #{line2}\n=42002 #{line2}\n.sykus-share-teacher #{line2}" +
            "\n" +
            "02 #{line3}\n=42003 #{line3}\n.sykus-share-admin #{line3}" +
            "\n" +
            "03 #{line4}\n=10001 #{line4}\n.sykus-group-1 #{line4}"

          next  # skip userdb-format checking
        end

        line1.should_not be_nil
        line2.should_not be_nil

        File.read(infile).strip.should == 
          "00 #{line1}\n=10001 #{line1}\n.user1 #{line1}" + "\n" +
          "01 #{line2}\n=10002 #{line2}\n.user2 #{line2}"
      end

      job.perform
    end
  end

end

