require 'common'

require 'jobs/webfilter/build_db_job'

module Sykus; module Webfilter

  # Deletes an Entry.
  class DeleteEntry < ServiceBase

    # @param [Integer] id Entry ID.
    def action(id)
      enforce_permission! :webfilter_write

      id = id.to_i
      entry = Entry.get(id)
      raise Exceptions::NotFound, 'Entry not found' if entry.nil?

      entry.destroy
      entity_evt = EntityEvent.new(EntitySet.new(Entry), id, true)
      EntityEventStore.save entity_evt

      Resque.enqueue BuildDBJob

      nil
    end
  end

end; end

