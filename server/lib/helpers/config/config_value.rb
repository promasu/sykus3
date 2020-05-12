module Sykus; module Config

  # Gets and sets config values
  module ConfigValue

    # Gets a config value.
    # @param [String] name Name of config value.
    # @return [Mixed] Config value (or nil if not found).
    def self.get(name)
      obj = Config::Value.first(name: name)
      return nil if obj.nil?

      # all data types saved as array, see comment in #set
      JSON.parse(obj.json_value, symbolize_names: true).first
    end

    # Sets a config value.
    # @param [String] name Name of config value.
    # @param [Mixed] value Value (can be any JSONable data type).
    def self.set(name, value)
      obj = Config::Value.first(name: name) || Config::Value.new(name: name)

      value.strip! if value.is_a? String

      # dump wrapped in array
      # because JSON.parse does not allow primitive data types to be
      # the root element
      obj.json_value = [ value ].to_json
      obj.save
    end

  end

end; end

