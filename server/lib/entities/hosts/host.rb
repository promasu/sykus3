module Sykus; module Hosts

  # User Entity representing a hardware client.
  class Host
    include DataMapper::Resource

    property :id, Serial, 
      max: 1e10,
      writer: :private

    property :name, String, 
      required: true,
      format: /^[a-z][a-z0-9]{2,19}$/,
      length: 3..20

    property :ip, IPAddress, 
      required: true,
      unique: true,
      unique_index: true

    property :mac, String,
      required: true,
      unique: true,
      unique_index: true,
      format: /^([0-9a-f]{2}:){5}[0-9a-f]{2}$/,
      length: 17

    property :cpu_speed, Integer,
      default: 0,
      required: true
    property :ram_mb, Integer,
      default: 0,
      required: true

    property :online, Boolean,
      required: true,
      default: false

    property :ready, Boolean,
      required: true,
      default: false

    validates_uniqueness_of :name, scope: :host_group

    belongs_to :host_group
  end

end; end

