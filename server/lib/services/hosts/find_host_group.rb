require 'common'


module Sykus; module Hosts

  # Finds Host Groups.
  class FindHostGroup < ServiceBase

    # Find host group given the id.
    # @param [Integer] id Host group ID.
    # @return [Hash] Host group data.
    def by_id(id)
      enforce_permission! :host_groups_read
      export_hg HostGroup.get(id)
    end

    # Find all host groups.
    # @return [Array] Array of host group data.
    def all
      enforce_permission! :host_groups_read
      HostGroup.all.map { |hg| export_hg hg }
    end

    private 
    def export_hg(hg)
      raise Exceptions::NotFound, 'Host Group not found' if hg.nil?

      select_entity_props(hg, [ :id, :name ])
    end
  end

end; end

