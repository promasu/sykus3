module Sykus; module Users

  # User Entity representing a real-world person user-account.
  class User
    include DataMapper::Resource

    property :id, Serial, 
      max: 1e10,
      writer: :private

    property :username, String, 
      required: true,
      unique_index: true, 
      unique: true, 
      format: /^[a-z]{2,12}[0-9]{0,3}$/,
      length: 2..15 

    property :first_name, String, 
      length: 1..50, 
      required: true,
      accessor: :private
    property :last_name, String, 
      length: 1..50, 
      required: true,
      accessor: :private

    property :birthdate, String,
      required: true,
      length: (10..10)

    validates_with_block :birthdate do
      begin
        Date.strptime @birthdate, '%d.%m.%Y'
        true
      rescue 
        [ false, 'Invalid birthdate' ]
      end
    end

    property :password_expired, Boolean,
      required: true
    property :password_nt, String,
      required: true,
      length: 32..32,
      lazy: [ :password ]
    property :password_sha256, String,
      required: true,
      length: 64..64,
      lazy: [ :password ]
    property :password_initial, String,
      required: false,
      length: 3..20

    property :quota_used_mb, Integer,
      default: 0

    # DO NOT CHANGE the following enums. 
    # If new values are required, APPEND them.
    # DM does not use real ENUMs but maps the 
    # array-index to an Integer column.
    property :position_group, 
      Enum[ :person, :student, :teacher ], 
      required: true

    property :admin_group, 
      Enum[ :none, :junior, :senior, :super ], 
      required: true


    belongs_to :user_class, 
      required: false
    validates_presence_of :user_class, 
      :if => ->(u) { u.position_group == :student }

    has n, :user_groups, through: Resource

    has n, :sessions

    has n, :events, 'Calendar::Event'

    # Neat debugging.
    def inspect
      "#{username}[#{id}]"
    end

    # Gets the UNIX system UID.
    def system_id
      id + 10000
    end

    # Gets the full user name. 
    # @return [FullUserName] Full user name.
    def full_name
      FullUserName.new(@first_name, @last_name)
    end

    # Sets the full user name.
    # @param [FullUserName] name Full user name.
    def full_name=(name)
      raise Exceptions::Input unless name.is_a? FullUserName
      name.validate!

      self.first_name = name.first_name
      self.last_name = name.last_name
    end

  end

end; end

