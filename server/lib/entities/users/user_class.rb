module Sykus; module Users

  # Entity representing a school class. Users can be members of a
  # school class (optional).
  class UserClass
    include DataMapper::Resource

    property :id, Serial,
      writer: :private

    property :name, String, 
      length: 1..10,
      required: true,
      unique: true,
      unique_index: true

    property :grade, Integer,
      min: 1,
      max: 13,
      required: false

    has n, :users

    has n, :events, 'Calendar::Event'
  end

end; end

