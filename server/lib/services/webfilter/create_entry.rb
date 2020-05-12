require 'common'

require 'jobs/webfilter/build_db_job'

module Sykus; module Webfilter

  # Creates a new Entry.
  class CreateEntry < ServiceBase

    # @param [Hash] args Hash of new entry attributes. 
    # @return [Hash/Integer] Entry ID.
    def action(args)
      enforce_permission! :webfilter_write

      entry = Entry.new select_args(args, [ :domain, :comment, :type ])

      validate_entity! entry

      entry.save
      entity_evt = EntityEvent.new(EntitySet.new(Entry), entry.id, false)
      EntityEventStore.save entity_evt

      Resque.enqueue BuildDBJob

      { id: entry.id }      
    end
  end

end; end

