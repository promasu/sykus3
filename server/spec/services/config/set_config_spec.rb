require 'spec_helper'

require 'services/config/set_config'

require 'jobs/users/update_radius_secret_job'

module Sykus

  describe Config::SetConfig do
    let (:identity) { IdentityTestGod.new } 
    let (:set_config) { Config::SetConfig.new identity }

    let (:string_values) {%w{
      school_name 
      smartboard_serial 
      radius_secret wlan_ssid wlan_key
    }}

    it 'should set correct config' do
      data = {}
      string_values.each do |name|
        data[name.to_sym] = name
      end

      set_config.run data

      string_values.each do |name|
        Config::ConfigValue.get(name).should == name
      end

      Resque.dequeue(Users::UpdateRADIUSSecretJob).should == 1
    end

    it 'should work without data' do
      set_config.run({})
    end

    context 'errors' do
      it 'raises on invalid config data' do
        expect {
          set_config.run school_name: 'le "fancy" school'
        }.to raise_error Exceptions::Input
      end

      it '#run raises on permission violation' do
        check_service_permission(:config_edit, Config::SetConfig, :run, {})
      end
    end
  end

end

