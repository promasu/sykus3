require 'spec_helper'

require 'services/config/get_config'

module Sykus

  describe Config::GetConfig do
    let (:identity) { IdentityTestGod.new } 
    let (:get_config) { Config::GetConfig.new identity }

    context 'configured' do
      before :each do
        Config::ConfigValue.set('school_name', 'school')
        Config::ConfigValue.set('smartboard_serial', 'serial')
        Config::ConfigValue.set('radius_secret', 'secret1')
        Config::ConfigValue.set('wlan_ssid', 'ssid')
        Config::ConfigValue.set('wlan_key', 'key2')
      end

      it 'should return correct config' do
        res = get_config.run

        res[:school_name].should == 'school'
        res[:smartboard_serial].should == 'serial'
        res[:radius_secret].should == 'secret1'
        res[:wlan_ssid].should == 'ssid'
        res[:wlan_key].should == 'key2'
      end
    end

    context 'errors' do
      it '#run raises on permission violation' do
        check_service_permission(:config_edit, Config::GetConfig, :run)
      end
    end
  end

end

