module Sykus; module Users

  # Represents a full user name.
  class FullUserName
    attr_reader :first_name, :last_name

    # Constructor. Strips input.
    # @param [String] first_name First name.
    # @param [String] last_name Last name.
    def initialize(first_name, last_name)
      @first_name = first_name.strip
      @last_name = last_name.strip
    rescue
      raise Exceptions::Input, 'Invalid FullUserName'
    end

    # Validation.
    def validate!(*args)
      ei = Exceptions::Input
      [ :first_name, :last_name ].each do |s|
        raise ei, s.to_s + ' must be a string' unless self.send(s).is_a? String
        raise ei, s.to_s + ' must not be empty' unless self.send(s).length > 0
        unless /^[a-z\- ]+$/.match NormalizeString.run(self.send(s))
          raise ei, s.to_s + ' must not contain special chars'
        end
      end
    end

    # Return full name.
    def to_s
      "#{@first_name} #{@last_name}"
    end

    # Equality.
    def ==(other)
      self.class == other.class && state == other.state
    end

    protected 
    def state 
      [ @first_name, @last_name ]
    end

  end

end; end

