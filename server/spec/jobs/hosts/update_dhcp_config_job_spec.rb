require 'spec_helper'

require 'jobs/hosts/update_dhcp_config_job'

module Sykus

  describe Hosts::UpdateDHCPConfigJob do
    include FakeFS::SpecHelpers
    before { FileUtils.mkdir_p '/etc/dhcp' }

    it 'generates a correct config file and restarts server' do
      hg = Factory Hosts::HostGroup, name: 'cluster'
      Factory Hosts::Host, name: 'glados', host_group: hg,
        ip: '10.42.100.1', mac: '00:1c:de:ad:be:ef'

      job = Hosts::UpdateDHCPConfigJob
      job.should_receive(:system).with \
        'sudo stop isc-dhcp-server; sudo start isc-dhcp-server'

      job.perform

      conf = File.read('/etc/dhcp/sykus.dynamic.conf').strip
      conf.should == 
        'host cluster-glados { hardware ethernet 00:1c:de:ad:be:ef; ' +
          'fixed-address 10.42.100.1; option host-name "cluster-glados"; ' +
          'option pxelinux.configfile "conf.d/001cdeadbeef"; }' 
    end
  end

end

