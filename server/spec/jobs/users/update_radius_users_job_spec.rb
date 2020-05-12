require 'spec_helper'

require 'jobs/users/update_radius_users_job'

module Sykus

  describe Users::UpdateRADIUSUsersJob do
    include FakeFS::SpecHelpers
    before { FileUtils.mkdir_p '/etc/freeradius' }

    let! (:u1) {
      Factory Users::User, username: 'user1',
      password_expired: false, password_nt: SecureRandom.hex(32)
    }

    let! (:u2) {
      Factory Users::User, username: 'user2',
      password_expired: false, password_nt: SecureRandom.hex(32)
    }

    let! (:u3) {
      Factory Users::User, username: 'user3', password_expired: true
    }

    let (:users_file) { Users::UpdateRADIUSUsersJob::USERS_FILE }

    let (:job) { Users::UpdateRADIUSUsersJob }

    def userline(user)
      "#{user.username} NT-Password := \"#{user.password_nt}\""
    end

    it 'generates correct users file' do
      job.should_receive(:system).once.with \
        'sudo /etc/init.d/freeradius reload'

      job.perform

      password = Config::ConfigValue.get 'radius_client_password'
      password.should be_a String
      password.length.should > 15

      cli_hash = NTHash.get Config::ConfigValue.get('radius_client_password') 

      File.read(users_file).strip.should ==
        ("sykus.client NT-Password := \"#{cli_hash}\"\n" +
         userline(u1) + "\n" + userline(u2))
    end

    it 'does not restart service if config is unchanged' do
      job.should_receive(:system).once

      2.times { job.perform }
    end


    it 'works with already set client user password' do
      job.should_receive(:system).once

      Config::ConfigValue.set('radius_client_password', 'badwolf2')
      job.perform

      cli_hash = NTHash.get 'badwolf2' 
      File.read(users_file).strip.split("\n").first.should ==
        "sykus.client NT-Password := \"#{cli_hash}\""
    end
  end

end

