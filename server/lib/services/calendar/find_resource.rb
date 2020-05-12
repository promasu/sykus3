require 'common'

module Sykus; module Calendar

  # Finds Calendar Resources.
  class FindResource < ServiceBase

    # Find resource given the id.
    # @param [Integer] id Resource ID.
    # @return [Hash] Resource data.
    def by_id(id)
      enforce_permission! :cal_resource_read
      export_resource Resource.get(id)
    end

    # Find all resource.
    # @return [Array] Array of resource data.
    def all
      enforce_permission! :cal_resource_read
      Resource.all.map { |r| export_resource r }
    end

    private 
    def export_resource(resource)
      raise Exceptions::NotFound, 'Resource not found' if resource.nil?

      select_entity_props(resource, [ :id, :name, :active ])
    end
  end

end; end

