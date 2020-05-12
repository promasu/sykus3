module Sykus; module Webfilter

  # Webfilter Blacklist/Whitelist entry.
  class Entry
    include DataMapper::Resource

    property :id, Serial, 
      max: 1e10,
      writer: :private

    property :domain, String, 
      required: true,
      unique: true,
      unique_index: true,
      format: /^[a-z0-9\-\.]*$/,
      length: 3..100

    property :comment, Text,
      required: false,
      lazy: false

    # DO NOT CHANGE the following enum. 
    # If new values are required, APPEND them.
    # DM does not use real ENUMs but maps the 
    # array-index to an Integer column.
    property :type,
      Enum[ :white_all, :nonstudents_only, :black_all ],
      required: true
  end

end; end

