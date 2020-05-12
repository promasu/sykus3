module Sykus; module Calendar

  # Calendar event.
  class Event
    include DataMapper::Resource

    property :id, Serial, 
      max: 1e10,
      writer: :private

    property :start, DateTime, 
      required: true

    property :end, DateTime,
      required: true
    validates_with_block :end do
      [ @end > @start, 'End needs to be after start' ]
    end

    property :all_day, Boolean,
      required: true

    property :title, String,
      required: true,
      length: 5..100

    property :location, String,
      length: 100

    property :created_at, DateTime


    belongs_to :user, 'Users::User',
      required: true

    # DO NOT CHANGE the following enum. 
    # If new values are required, APPEND them.
    # DM does not use real ENUMs but maps the 
    # array-index to an Integer column.
    property :type, 
      Enum[ :private, :global, :teacher, :grade, :class, :group, :resource ], 
      required: true

    belongs_to :user_class, 'Users::UserClass',
      required: false
    validates_presence_of :user_class, :if => ->(e) { e.type == :class }

    belongs_to :user_group, 'Users::UserGroup',
      required: false
    validates_presence_of :user_group, :if => ->(e) { e.type == :group }

    property :grade, Integer,
      required: false
    validates_presence_of :grade, :if => ->(e) { e.type == :grade }

    belongs_to :resource, 'Calendar::Resource',
      required: false
    validates_presence_of :resource, :if => ->(e) { e.type == :resource }

    # Gets the calendar id, a string representation of event type
    # and associated entity id
    def cal_id
      case type
      when :private
        "private:#{user.id}"
      when :global
        "global"
      when :teacher
        "teacher"
      when :grade
        "grade:#{grade}"
      when :class
        "class:#{user_class.id}"
      when :group
        "group:#{user_group.id}"
      when :resource
        "resource:#{resource.id}"
      end
    end

    # Sets the calendar type and associated entities by calendar id.
    # @param [String] str Calendar ID string
    def cal_id=(str)
      type, id = *str.split(':')

      id = id.to_i
      self.type = type.to_sym

      case self.type
      when :grade
        self.grade = id
      when :class
        self.user_class = Users::UserClass.get(id)
      when :group
        self.user_group = Users::UserGroup.get(id)
      when :resource
        self.resource = Resource.get(id)
      end
    end
  end

end; end

