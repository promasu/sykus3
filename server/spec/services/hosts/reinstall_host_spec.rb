require 'spec_helper'

require 'services/hosts/reinstall_host'
require 'jobs/hosts/update_pxe_link_job'

module Sykus

  describe Hosts::ReinstallHost do
    let (:identity) { IdentityTestGod.new } 
    let (:reinstall_host) { Hosts::ReinstallHost.new identity } 

    let (:host) { Factory Hosts::Host }
    let (:id) { host.id }

    context 'readiness' do
      it 'works if host was ready' do
        host.ready = true
        host.save

        reinstall_host.run(id)

        ref = Hosts::Host.get id
        ref.ready.should be_false
        check_entity_evt(EntitySet.new(Hosts::Host), id, false)
        Resque.dequeue(Hosts::UpdatePXELinkJob, id).should == 1
      end

      it 'works if host was not ready' do
        host.ready = false
        host.save

        reinstall_host.run(id)

        ref = Hosts::Host.get id
        ref.ready.should be_false
        check_entity_evt(EntitySet.new(Hosts::Host), id, false)
        Resque.dequeue(Hosts::UpdatePXELinkJob, id).should == 1
      end
    end

    context 'errors' do
      it '#run raises on permission violations' do
        check_service_permission(:hosts_update_delete, 
                                 Hosts::ReinstallHost, :run, 4200)
      end

      it '#run raises on invalid id' do
        expect {
          reinstall_host.run(4200)
        }.to raise_error Exceptions::NotFound
      end
    end
  end

end


