module Sykus

  # Represents an entity Object with optional sub-set parameter.
  class EntitySet
    attr_reader :entity_class, :sub_set

    # Initialize.
    # @param [EntityClass] entity_class Entity class.
    # @param [String] sub_set Sub-set string.
    def initialize(entity_class, sub_set = nil)
      raise unless sub_set.is_a?(String) || sub_set.nil?
      raise unless entity_class.ancestors.include? DataMapper::Resource

      @entity_class = entity_class
      @sub_set = sub_set
    end

    # Gets key string for use in Redis.
    def key
      return @entity_class.name if sub_set.nil?
      @entity_class.name + ':' + @sub_set
    end

    # Equality.
    def ==(other)
      self.class == other.class && state == other.state
    end

    protected
    def state
      [ @entity_class, @sub_set ]
    end
  end

end

