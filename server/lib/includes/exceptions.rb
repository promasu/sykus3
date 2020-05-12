module Sykus

  # Custom exception classes.
  module Exceptions

    # Indicates invalid user input.
    class Input < StandardError
      # Returns error message.
      # @return [String]
      def to_s 
        "Input Error (#{super})"
      end
    end

    # Indicates that the requested entity could not be found.
    class NotFound < StandardError
      # Returns error message.
      # @return [String]
      def to_s
        "Not found (#{super})"
      end
    end

    # Indicates that the current Identity context lacks 
    # the required permission to fulfill the requested action.
    class Permission < StandardError 
      # Permission symbol
      attr_reader :permission

      # @param [Symbol] permission Permission symbol.
      def initialize(permission)
        @permission = permission
      end

      # Returns error message.
      # @return [String]
      def to_s
        "Permission #{@permission.to_s} required"
      end
    end
  end

end

