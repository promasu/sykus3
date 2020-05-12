require 'spec_helper'

require 'services/config/get_public_config'

module Sykus

  describe Config::GetPublicConfig do
    let (:identity) { IdentityAnonymous.new } 
    let (:get_public_config) { Config::GetPublicConfig.new identity }

    let (:ready) { false }

    let (:hg) { Factory Hosts::HostGroup, name: 'hg01' }
    let (:host) { 
      Factory Hosts::Host, ready: ready, name: 'pc01', host_group: hg 
    }
    let (:ip) { IPAddr.new '127.0.0.1' }

    subject { get_public_config.run ip }

    before (:each) { Timecop.freeze }
    after (:each) { Timecop.return }

    context 'default state' do
      it 'should return correct config' do
        res = subject

        res[:demo].should == false
        res[:school_name].should == '(set up school name)'
        res[:app_env].should == :test

        res[:servertime].should == Time.now.to_i

        res[:hostname].should == ''
        res[:net_int].should == false
        res[:net_cli].should == false
        res[:host_ready].should == false
        res[:host_group].should be_nil
      end
    end

    context 'configured state' do
      before :each do
        Config::ConfigValue.set('demo', true)
        Config::ConfigValue.set('school_name', 'school1')
      end

      it 'should return correct config' do
        res = subject

        res[:demo].should == true
        res[:school_name].should == 'school1'
      end
    end

    context 'nil ip' do
      let (:ip) { nil }

      it 'should return correct config' do
        res = subject

        res[:hostname].should == ''
        res[:net_int].should == false
        res[:net_cli].should == false
        res[:host_ready].should == false
        res[:host_group].should be_nil
      end
    end

    context 'internal ip (no cli)' do
      let (:ip) { IPAddr.new '10.42.200.1' }

      it 'should return correct config' do
        res = subject

        res[:hostname].should == ''
        res[:net_int].should == true
        res[:net_cli].should == false
        res[:host_ready].should == false
        res[:host_group].should be_nil
      end
    end

    context 'internal ip (cli range, no host)' do
      let (:ip) { IPAddr.new '10.42.100.1' }

      it 'should return correct config' do
        res = subject

        res[:hostname].should == ''
        res[:net_int].should == true
        res[:net_cli].should == false
        res[:host_ready].should == false
        res[:host_group].should be_nil
      end
    end

    context 'internal ip (cli range, with host, not ready)' do
      let (:ip) { host.ip }

      it 'should return correct config' do
        res = subject

        res[:hostname].should == 'hg01-pc01'
        res[:net_int].should == true
        res[:net_cli].should == true
        res[:host_ready].should == false
        res[:host_group].should == host.host_group.id
      end
    end

    context 'internal ip (cli range, with host, ready)' do
      let (:ready) { true }
      let (:ip) { host.ip }

      it 'should return correct config' do
        res = subject

        res[:hostname].should == 'hg01-pc01'
        res[:net_int].should == true
        res[:net_cli].should == true
        res[:host_ready].should == true
        res[:host_group].should == host.host_group.id
      end
    end

  end
end

