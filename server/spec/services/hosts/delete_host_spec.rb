require 'spec_helper'

require 'services/hosts/delete_host'
require 'jobs/hosts/update_dhcp_config_job'

module Sykus

  describe Hosts::DeleteHost do
    let (:identity) { IdentityTestGod.new } 
    let (:delete_host) { Hosts::DeleteHost.new identity }

    let! (:host) { Factory Hosts::Host }
    let! (:id) { host.id }
    let! (:session) { Factory Users::Session, host: host }

    context 'input parameters' do
      it 'works with host id' do
        delete_host.run id

        Hosts::Host.get(id).should be_nil
        check_entity_evt(EntitySet.new(Hosts::Host), id, true)
        Resque.dequeue(Hosts::UpdateDHCPConfigJob).should == 1
      end
    end

    context 'errors' do
      it 'raises on permission violation' do
        check_service_permission(:hosts_update_delete, 
                                 Hosts::DeleteHost, :run, 1)
      end

      it 'raises on invalid id' do
        expect {
          delete_host.run 4200
        }.to raise_error Exceptions::NotFound
      end
    end
  end

end

