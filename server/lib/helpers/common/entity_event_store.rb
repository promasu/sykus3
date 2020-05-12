module Sykus

  # Stores +EntityEvent+ instances into Redis DB.
  module EntityEventStore
    # Prefix for Redis entries.
    STORE_PREFIX = 'EntityEvent.'

    # Saves the given EntityEvent
    # @param [EntityEvent] entity_evt Event to be saved.
    def self.save(entity_evt)
      raise unless entity_evt.is_a?(EntityEvent)

      key = STORE_PREFIX + entity_evt.entity_set.key
      data = entity_evt.id * (entity_evt.deleted ? -1 : 1)

      # delete opposite entry to avoid race contitions.
      # adding the same entry twice just updates the timestamp.
      REDIS.multi do
        REDIS.zrem(key, (-data).to_s)
        REDIS.zadd(key, Time.now.to_f, data.to_s)
      end
      nil
    end

    # Returns all EntityEvents ranging
    # from the given timestamp to the current time.
    # @param [EntitySet] entity_set Entity Set.
    # @return [EntityEvent[]] Array of EntityEvent instances.
    def self.get_events_since(entity_set, timestamp)
      key = STORE_PREFIX + entity_set.key
      data = REDIS.zrangebyscore(key, timestamp.to_f.to_s, '+inf')

      data.map do |id|
        EntityEvent.new(entity_set, id.to_i.abs, (id.to_i < 0))
      end
    end
  end

end

