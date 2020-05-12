require 'common'

require 'jobs/users/update_radius_secret_job'

module Sykus; module Config

  # Sets all config information.
  class SetConfig < ServiceBase

    # @param [Hash] args Hash of config data.
    # Use #run to prevent logging (no sensitive data in logs!)
    def run(args)
      enforce_permission! :config_edit

      %w{
        school_name 
        smartboard_serial 
        wlan_ssid wlan_key radius_secret
      }.each do |name|
        value = args[name.to_sym]

        if value.is_a? String
          raise Exceptions::Input, 'Invalid chars' if value.match(/"/)
          ConfigValue.set(name, value.strip)
        end
      end

      Resque.enqueue Users::UpdateRADIUSSecretJob

      nil
    end
  end

end; end

