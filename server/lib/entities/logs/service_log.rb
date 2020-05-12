module Sykus; module Logs

  # Service action log record.
  class ServiceLog
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

    property :service, String,
      required: true,
      length: 2..40

    property :input, Text, lazy: false
    property :output, Text, lazy: false
  end

end; end

