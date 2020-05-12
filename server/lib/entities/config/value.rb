module Sykus; module Config

  # Config value.
  class Value
    include DataMapper::Resource

    property :id, Serial, 
      max: 1e10,
      writer: :private

    property :name, String, 
      required: true,
      unique: true,
      format: /^[a-z0-9_]{2,50}$/,
      unique_index: true

    property :json_value, Text,
      required: true,
      lazy: false
  end

end; end

