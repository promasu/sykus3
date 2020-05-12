module Sykus; module Hosts

  # Client Software Package.
  class Package
    include DataMapper::Resource

    property :id, Serial, 
      max: 1e10,
      writer: :private

    property :id_name, String, 
      required: true,
      unique: true,
      unique_index: true,
      format: /^[a-z0-9\-]*$/,
      length: 3..20

    property :name, String,
      required: true,
      unique: true,
      length: 3..50

    property :category, String,
      required: true,
      length: 3..50

    property :text, Text,
      required: true,
      lazy: false

    property :default, Boolean,
      required: true
    property :selected, Boolean,
      required: true
    property :installed, Boolean,
      required: true

  end

end; end

