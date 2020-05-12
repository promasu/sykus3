require 'common'


module Sykus; module Hosts

  # Finds Packages.
  class FindPackage < ServiceBase

    # Find package given their package id.
    # @param [Integer] id Package ID.
    # @return [Hash] Package data.
    def by_id(id)
      enforce_permission! :packages_read
      export_package Package.get(id)
    end

    # Find all packages.
    # @return [Array] Array of package data.
    def all
      enforce_permission! :packages_read
      Package.all.map { |package| export_package package }
    end

    private 
    def export_package(package)
      raise Exceptions::NotFound, 'Package not found' if package.nil?

      select_entity_props(package, [ :id, :id_name, :name, :category, 
                          :text, :default, :selected, :installed ])
    end
  end

end; end

