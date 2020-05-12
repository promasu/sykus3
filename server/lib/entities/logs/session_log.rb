module Sykus; module Logs

  # Login/Logout action log record.
  class SessionLog
    include DataMapper::Resource

    property :id, Serial, 
      max: 1e10,
      writer: :private

    property :created_at, DateTime,
      index: true,
      writer: :private

    property :username, String,
      required: true,
      length: 2..20

    property :ip, IPAddress,
      required: false

    # DO NOT CHANGE the following enum. 
    # If new values are required, APPEND them.
    # DM does not use real ENUMs but maps the 
    # array-index to an Integer column.
    property :type, 
      Enum[ :login, :host_login, :auth ],
      required: true
  end

end; end

