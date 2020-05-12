require 'spec_helper'

require 'jobs/users/update_samba_job'

module Sykus

  describe Users::UpdateSambaJob do
    include FakeFS::SpecHelpers

    TIMEOUT = 0.4
    let (:job) { Users::UpdateSambaJob }
    let (:user) { 
      Factory Users::User, id: 1, username: 'user1', password_nt: 'a' * 32 
    }

    before :each do  
      FileUtils.mkdir_p '/tmp'
      user 
    end

    it 'updates a user correctly' do
      Etc.stub(:getpwnam).and_return { Struct.new(:uid).new(10001) }

      job.should_receive(:system) do |arg|
        cmd, file = arg.split(':')
        cmd.should == 'sudo pdbedit -i smbpasswd'

        File.read(file).strip.should == 
          "user1:10001:#{'X' * 32}:#{'A' * 32}:[UX         ]:LCT-00000000:" 
      end

      # make sure the nssdb test below does not result in a false positive
      Timeout::timeout(TIMEOUT/2.0) do
        job.perform 'user1'
      end
    end

    it 'waits for valid nss entry' do
      Etc.stub(:getpwnam).and_return { Struct.new(:uid).new(42) }

      expect {
        Timeout::timeout(TIMEOUT) { job.perform 'user1' }
      }.to raise_error Timeout::Error
    end

    it 'deletes a user correctly' do
      job.should_receive(:system).with 'sudo pdbedit -u user2 -x'
      job.perform 'user2'
    end
  end

end

