module Sykus; module Calendar

  # Entity representing a resource, i.e. a room or an item that can be
  # borrowed from the school.
  class Resource
    include DataMapper::Resource

    property :id, Serial,
      writer: :private

    property :name, String, 
      length: 2..50,
      required: true,
      unique: true,
      unique_index: true

    property :active, Boolean,
      required: true,
      default: true

    has n, :events, 'Calendar::Event'
  end

end; end

