require 'spec_helper'

require 'services/hosts/create_host'
require 'jobs/hosts/update_pxe_link_job'
require 'jobs/hosts/update_dhcp_config_job'

module Sykus

  describe Hosts::CreateHost do
    let (:create_host) { Hosts::CreateHost.new IdentityTestGod.new }

    let (:host_group) { Factory Hosts::HostGroup }
    let (:glados) {{
      name: 'glados',
      host_group: host_group.id,
      # works with mixed case
      mac: '00:1c:DE:ad:BE:ef',
    }}

    subject { create_host.run glados }

    it 'works with all required parameters' do
      result = subject

      id = result[:id]
      id.should be_a Integer

      host = Hosts::Host.get id
      host.name.should == 'glados'
      host.ip.should == IPAddr.new('10.42.100.1')
      host.mac.should == '00:1c:de:ad:be:ef'
      host.cpu_speed.should == 0
      host.ram_mb.should == 0
      host.host_group.should == host_group
      host.ready.should be_false

      check_entity_evt(EntitySet.new(Hosts::Host), id, false)
      Resque.dequeue(Hosts::UpdateDHCPConfigJob).should == 1
      Resque.dequeue(Hosts::UpdatePXELinkJob, id).should == 1
    end

    it 'works with host group name' do
      glados[:host_group] = host_group.name
      result = subject

      id = result[:id]
      id.should be_a Integer

      host = Hosts::Host.get id
      host.host_group.should == host_group
    end

    it 'creates a host with the next available ip address' do
      dummy = Factory.build Hosts::Host
      create_host.run({
        name: dummy.name, 
        host_group: host_group.id, 
        mac: dummy.mac 
      })

      result = subject
      id = result[:id]
      id.should be_a Integer
      host = Hosts::Host.get id
      host.ip.should == IPAddr.new('10.42.100.2')
    end

    context 'errors' do
      it '#run raises on permission violation' do
        check_service_permission(:hosts_create, Hosts::CreateHost, :run, {})
      end

      it 'raises on duplicate name' do
        create_host.run glados.merge({ 
          mac: Factory.build(Hosts::Host).mac
        })

        expect { subject }.to raise_error Exceptions::Input
      end

      it 'raises on duplicate mac' do
        create_host.run glados.merge({ name: 'randomname' })

        expect { subject }.to raise_error Exceptions::Input
      end
    end
  end

end

