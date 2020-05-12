require 'common'


module Sykus; module Webfilter

  # Finds Categories.
  class FindCategory < ServiceBase

    # Find category given their category id.
    # @param [Integer] id Category ID.
    # @return [Hash] Category data.
    def by_id(id)
      enforce_permission! :webfilter_read
      export_category Category.get(id)
    end

    # Find all categories.
    # @return [Array] Array of category data.
    def all
      enforce_permission! :webfilter_read
      Category.all.map { |category| export_category category }
    end

    private 
    def export_category(category)
      raise Exceptions::NotFound, 'Category not found' if category.nil?

      data = select_entity_props(category, [ :id, :name, :text ])
      data.merge({
        default: category.default.to_s,
        selected: category.selected.to_s,
      })
    end
  end

end; end

