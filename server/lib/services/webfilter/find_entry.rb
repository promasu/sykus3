require 'common'


module Sykus; module Webfilter

  # Finds Entries.
  class FindEntry < ServiceBase

    # Find entry given their entry id.
    # @param [Integer] id Entry ID.
    # @return [Hash] Entry data.
    def by_id(id)
      enforce_permission! :webfilter_read
      export_entry Entry.get(id)
    end

    # Find all categories.
    # @return [Array] Array of entry data.
    def all
      enforce_permission! :webfilter_read
      Entry.all.map { |entry| export_entry entry }
    end

    private 
    def export_entry(entry)
      raise Exceptions::NotFound, 'Entry not found' if entry.nil?

      data = select_entity_props(entry, [ :id, :domain, :comment ])
      data.merge({ 
        type: entry.type.to_s
      })
    end
  end

end; end

