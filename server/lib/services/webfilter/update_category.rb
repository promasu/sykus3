require 'common'

require 'jobs/webfilter/build_db_job'

module Sykus; module Webfilter

  # Updates a Category.
  class UpdateCategory < ServiceBase

    # @param [Integer] id Category ID.
    # @param [Hash] args Hash of new category attributes. 
    def action(id, args)
      enforce_permission! :webfilter_write

      category = Category.get(id.to_i)
      raise Exceptions::NotFound, 'Category not found' if category.nil?

      category.selected = args[:selected].to_sym

      validate_entity! category

      category.save
      entity_evt = EntityEvent.new(EntitySet.new(Category), category.id, false)
      EntityEventStore.save entity_evt

      Resque.enqueue BuildDBJob

      nil
    end
  end

end; end

