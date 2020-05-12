require 'common'


module Sykus; module Users

  # Creates a new User Class.
  class CreateUserClass < ServiceBase

    # @param [Hash] args Hash with name of new user class.
    # @return [Hash/Integer] User Class ID.
    def action(args)
      enforce_permission! :user_classes_write

      raise Exceptions::Input unless args[:name].is_a? String

      name = args[:name].strip
      grade = name.match(/^(\d+)/)
      grade = (grade && grade[1]) ? grade[1].to_i : nil

      uc = UserClass.new name: name, grade: grade

      validate_entity! uc

      uc.save
      entity_evt = EntityEvent.new(EntitySet.new(UserClass), uc.id, false)
      EntityEventStore.save entity_evt

      { id: uc.id }
    end
  end

end; end

