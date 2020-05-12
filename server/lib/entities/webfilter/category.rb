module Sykus; module Webfilter

  # Webfilter Blacklist category.
  class Category
    include DataMapper::Resource

    property :id, Serial, 
      max: 1e10,
      writer: :private

    property :name, String, 
      required: true,
      unique: true,
      unique_index: true,
      format: /^[a-z0-9\-\/]*$/,
      length: 3..40

    property :text, Text,
      required: true,
      lazy: false

    # DO NOT CHANGE the following enums. 
    # If new values are required, APPEND them.
    # DM does not use real ENUMs but maps the 
    # array-index to an Integer column.
    property :default, Enum[ :none, :students, :all ],
      required: true
    property :selected, Enum[ :none, :students, :all ],
      required: true
  end

end; end

