require 'common'

module Sykus; module Config

  # Gets all config information.
  class GetConfig < ServiceBase

    # @return [Hash] Hash of config data.
    def run
      enforce_permission! :config_edit

      result = {}
      %w{
        school_name 
        smartboard_serial 
        wlan_ssid wlan_key radius_secret
      }.each do |name|
        result[name.to_sym] = ConfigValue.get name
      end
      result
    end
  end

end; end

