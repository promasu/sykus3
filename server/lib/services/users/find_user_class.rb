require 'common'


module Sykus; module Users

  # Finds User Classes.
  class FindUserClass < ServiceBase

    # Find user class given the id.
    # @param [Integer] id User class ID.
    # @return [Hash] User class data.
    def by_id(id)
      enforce_permission! :user_classes_read
      export_uc UserClass.get(id)
    end

    # Find all user classes.
    # @return [Array] Array of user class data.
    def all
      enforce_permission! :user_classes_read
      UserClass.all.map { |uc| export_uc uc }
    end

    private 
    def export_uc(uc)
      raise Exceptions::NotFound, 'User class not found' if uc.nil?

      select_entity_props(uc, [ :id, :name, :grade ])
    end
  end

end; end
