module Sykus

  # Base class for Service classes. Includes helper methods.
  class ServiceBase

    # Initialize a Service instance.
    # @param [Identity] identity Identity instance.
    def initialize(identity)
      raise unless identity.class.ancestors.include? IdentityBase
      @identity = identity
    end

    # Runs the main service action and logs parameters and return values.
    # If no logging is required, override this method.
    def run(*args)
      ret = action(*args)
      ret = ret.to_hash unless ret.nil?

      str_args = args.map do |arg| 
        if arg.is_a? Hash
          arg.reject do |k| 
            k.to_s.include?('password') || k.to_s.include?('session')
          end
        else
          arg
        end
      end

      str_ret = (ret || {}).reject { |k| k.to_s == 'password' }
      classname = self.class.to_s.split('::')[1..-1].join('::')

      Logs::ServiceLog.create username: @identity.name, service: classname,
        input: str_args.to_json, output: str_ret.to_json

      ret
    end

    # Main action method. Must be overridden if #run is used.
    def action
      raise 'You must override this method.'
    end

    # Enforces that the service Identity has the given
    # permission. Raises if permission is not present.
    # @param [Symbol] permission Permission symbol.
    def enforce_permission!(permission)
      @identity.enforce_permission! permission
    end

    # Validates that an entity instance is valid
    # and raises an `Input` exception with detailed error messages.
    # @param [Object] instance Entity instance.
    # @return [nil]
    def validate_entity!(instance)
      return if instance.valid?
      raise Exceptions::Input.new(instance.errors.full_messages.join('. '))
    end

    # Returns a filtered hash with specified keys only.
    # @param [Hash] args Input Hash.
    # @param [Array] symbols List of all keys that are to be returned.
    # @return [Hash] Filtered Hash.
    def select_args(args, symbols)
      args.select do |key|
        symbols.include? key.to_sym
      end
    end

    # Return a hash with the specified entity properties.
    # @param [Object] instance Entity instance.
    # @param [Array] symbols List of requested properties.
    # @return [Hash] Hash with properties.
    def select_entity_props(instance, symbols)
      data = {}
      symbols.each do |key|
        data[key] = instance.send key
      end
      data
    end
  end

end

