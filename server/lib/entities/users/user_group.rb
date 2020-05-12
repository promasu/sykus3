module Sykus; module Users

  # Entity representing a user group. Groups can be 
  # created by users to represent an arbitrary set of users.
  # Users can be members of multiple groups. Groups have one
  # owner who can manage group membership.
  class UserGroup
    include DataMapper::Resource

    property :id, Serial, 
      max: 1e10,
      writer: :private

    property :name, String,
      required: true,
      format: /^[^\/\[\]]+$/,
      length: 2..50


    belongs_to :owner, 'User'

    has n, :users, through: Resource

    has n, :events, 'Calendar::Event'

    # Gets the UNIX system GID.
    def system_id
      id + 10000
    end

  end

end; end

