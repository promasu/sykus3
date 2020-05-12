module Sykus; module Users

  # User Session. Can belong to a host (logged in on sykus client).
  class Session
    include DataMapper::Resource

    property :id, String,
      length: 64..64,
      required: true,
      key: true,
      unique: true

    property :ip, IPAddress,
      required: false

    property :updated_at, DateTime

    belongs_to :user
    belongs_to :host, 'Hosts::Host', required: false
  end

end; end

