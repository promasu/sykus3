require 'spec_helper'

require 'jobs/hosts/update_pxe_link_job'

module Sykus

  describe Hosts::UpdatePXELinkJob do
    dir = '/var/lib/sykus3/tftp/conf.d' 
    include FakeFS::SpecHelpers
    before { FileUtils.mkdir_p dir }

    let (:host) { Factory Hosts::Host, mac: '00:1c:de:ad:be:ef', ready: ready }
    let (:file) { dir + '/' + host.mac.gsub(':', '') }

    context 'when ready' do
      let (:ready) { true }
      it 'generates a correct link' do
        Hosts::UpdatePXELinkJob.perform host.id
        File.readlink(file).should == '../local.conf'
      end
    end

    context 'when not ready' do 
      let (:ready) { false }
      it 'generates a correct link' do
        Hosts::UpdatePXELinkJob.perform host.id
        File.readlink(file).should == '../sni.conf'
      end
    end
    end

end

