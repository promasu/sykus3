require 'spec_helper'

require 'services/hosts/find_host'

module Sykus

  describe Hosts::FindHost do
    let (:host) { Factory Hosts::Host }
    let (:find_host) { Hosts::FindHost.new IdentityTestGod.new }

    def check_host(result, ref)
      result[:id].should == ref.id
      result[:name].should == ref.name
      result[:ip].should == ref.ip.to_s
      result[:mac].should == ref.mac
      result[:online].should == ref.online
      result[:ready].should == ref.ready
      result[:cpu_speed].should == ref.cpu_speed
      result[:ram_mb].should == ref.ram_mb
      result[:host_group].should == ref.host_group.id
    end

    context 'permission violations' do
      it 'raises on #all' do
        check_service_permission(:hosts_read, Hosts::FindHost, :all)
      end

      it 'raises on #by_id' do
        check_service_permission(:hosts_read, Hosts::FindHost, :by_id, 42)
      end
    end

    context 'returns all hosts' do
      subject { find_host.all }

      before :each do
        3.times { Factory Hosts::Host, cpu_speed: 42 }
      end

      it { should be_a Array }

      it 'returns correct number of hosts' do 
        subject.count.should == 3
      end

      it 'returns correct host data' do
        subject.each do |host|
          host[:cpu_speed].should == 42
        end
      end
    end

    context 'finds host by id' do
      it 'finds correct host with all attributes' do
        res = find_host.by_id(host.id)
        check_host res, host
      end

      it 'raises on invalid host' do
        expect {
          find_host.by_id(42000)
        }.to raise_error Exceptions::NotFound
      end
    end
  end

end

