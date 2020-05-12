require 'spec_helper'

require 'jobs/users/update_radius_secret_job'

module Sykus

  describe Users::UpdateRADIUSSecretJob do
    include FakeFS::SpecHelpers
    before { FileUtils.mkdir_p '/etc/freeradius' }

    let (:job) { Users::UpdateRADIUSSecretJob }

    def check_clients_file(secret = nil)
      secret ||= Config::ConfigValue.get('radius_secret')
      File.read(Users::UpdateRADIUSSecretJob::CLIENTS_FILE).strip.should ==
        "client 10.42.0.0/16 {\nsecret = #{secret}\n}"
    end

    it 'generates correct clients file' do
      job.should_receive(:system).once.with \
        'sudo /etc/init.d/freeradius restart'

      job.perform

      secret = Config::ConfigValue.get 'radius_secret'
      secret.should be_a String
      secret.length.should > 15

      check_clients_file
    end

    it 'does not restart service if config is unchanged' do
      job.should_receive(:system).once

      2.times { job.perform }
    end

    it 'works with already set secret' do
      Config::ConfigValue.set('radius_secret', 'badwolf')

      job.should_receive(:system).once
      job.perform

      check_clients_file 'badwolf'
    end
  end

end

