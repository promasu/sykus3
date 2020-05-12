require 'spec_helper'

require 'services/hosts/update_host'
require 'jobs/hosts/update_dhcp_config_job'

module Sykus

  describe Hosts::UpdateHost do
    let (:identity) { IdentityTestGod.new } 
    let (:update_host) { Hosts::UpdateHost.new identity } 

    let (:host) { Factory Hosts::Host }
    let (:id) { host.id }
    let (:new_group) { Factory Hosts::HostGroup }

    context 'input parameters' do
      it 'works with all attributes' do
        update_host.run(id, {
          name: 'newpc',
          host_group: new_group.id,
        })

        ref = Hosts::Host.get id
        ref.name.should == 'newpc'
        ref.host_group.should == new_group

        check_entity_evt(EntitySet.new(Hosts::Host), id, false)
        Resque.dequeue(Hosts::UpdateDHCPConfigJob).should == 1
      end

      it 'works with empty data' do
        ref = Hosts::Host.get(id).to_json
        update_host.run id, {}
        Hosts::Host.get(id).to_json.should == ref
      end
    end

    context 'errors' do
      it '#run raises on permission violations' do
        check_service_permission(:hosts_update_delete, 
                                 Hosts::UpdateHost, :run, 4200, {})
      end

      it '#run raises on invalid id' do
        expect {
          update_host.run(4200, {})
        }.to raise_error Exceptions::NotFound
      end
    end
  end

end

