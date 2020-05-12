require 'common'


module Sykus; module Hosts

  # Updates a Package.
  class UpdatePackage < ServiceBase

    # @param [Integer] id Package ID.
    # @param [Hash] args Hash of new package attributes. 
    def action(id, args)
      enforce_permission! :packages_write

      package = Package.get(id.to_i)
      raise Exceptions::NotFound, 'Package not found' if package.nil?

      package.attributes = select_args(args, [ :selected ])

      validate_entity! package

      package.save
      entity_evt = EntityEvent.new(EntitySet.new(Package), package.id, false)
      EntityEventStore.save entity_evt
      nil
    end
  end

end; end

