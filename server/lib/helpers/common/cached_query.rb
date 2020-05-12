module Sykus

  # Caches Database query results in Redis for performance reasons.
  module CachedQuery
    # Prefix for Redis entries.
    STORE_PREFIX = 'CachedQuery.'

    # Returns cached version of query. Updates cache automatically
    # using EntityEvents. If there is no cache entry, 
    # generate one with all data from query.
    # @param [DataMapper::Query] query DB query.
    # @param [EntitySet] entity_set Entity set that matches query (!).
    # @param [block] export_cb Block converting a given DM resource to a hash.
    def self.get_cached(query, entity_set, &export_cb) 
      key = STORE_PREFIX + entity_set.key

      # set before anything is received to avoid race conditions
      mtime_new = Time.now.to_f
      update_data = false

      # get mtime before data to avoid race conditions
      mtime = REDIS.get(key + '.mtime')
      data = REDIS.get(key + '.data')

      if mtime.nil? || data.nil?
        data = {}
        update_data = true

        query.map do |row| 
          result = yield row
          raise unless result[:id].is_a? Integer

          # save id as string keys for JSON serialization
          data[result[:id].to_s] = result
        end
      else
        data = JSON.parse data

        events = EntityEventStore.get_events_since(entity_set, mtime.to_f)
        update_data = true unless events.empty?

        events.each do |event|
          if event.deleted
            data.delete event.id.to_s
          else
            data[event.id.to_s] = yield(entity_set.entity_class.get(event.id))
          end
        end
      end

      if update_data
        REDIS.multi do
          REDIS.set(key + '.data', data.to_json)
          REDIS.set(key + '.mtime', mtime_new)
        end
      end

      data.values
    end
  end

end

