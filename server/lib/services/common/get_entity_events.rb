require 'common'


module Sykus

  # Entity Event Getter Service
  class GetEntityEvents < ServiceBase

    # Fetches all EntityEvents that are stored for the given
    # entity class. Returns empty lists if timestamp is <= 0.
    # This can be used to get an initial timestamp in a client app.
    # @param [EntitySet] entity_set Entity set to get events for.
    # @param [Float] timestamp Beginning of event range, UNIX timestamp.
    # @return [Hash] Hash with +updated+, +deleted+, and +timestamp+
    #   properties. +updated+ and +deleted+ are Arrays of Entity IDs, 
    #   +timestamp+ is the current timestamp.
    def get_events(entity_set, timestamp)
      enforce_permission! :common_entity_events

      updated = []
      deleted = []

      # avoid race conditions and get new timestamp before query
      new_timestamp = Time.now.to_f

      if timestamp.to_f > 0
        data = EntityEventStore.get_events_since(entity_set, timestamp)
        data.each do |entity|
          (entity.deleted ? deleted : updated) << entity.id
        end
      end

      { updated: updated, deleted: deleted, timestamp: new_timestamp }
    end
  end

end

