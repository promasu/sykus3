module Sykus

  # Represents an event that has happened to an entity instance.
  # Events can either be +update+ with includes creation
  # or +deleted+ which indicates instace deletion.
  class EntityEvent
    attr_reader :entity_set, :id, :deleted

    # Initialize.
    # @param [Array/Class] entity_set Entity Set.
    # @param [Integer] id Instance ID
    # @param [Boolean] deleted Instance deleted?
    def initialize(entity_set, id, deleted)
      raise unless entity_set.is_a? EntitySet
      raise unless id.is_a? Integer 

      @entity_set = entity_set
      @id = id
      @deleted = !!deleted
    end

    # Equality.
    def ==(other)
      self.class == other.class && state == other.state
    end

    protected
    def state
      [ @entity_set, @id, @deleted ]
    end
  end

end

