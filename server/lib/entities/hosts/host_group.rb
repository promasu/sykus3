module Sykus; module Hosts

  # Entity representing a group of hardware hosts.
  class HostGroup
    include DataMapper::Resource

    property :id, Serial, 
      max: 1e10,
      writer: :private

    property :name, String,
      required: true,
      unique: true,
      unique_index: true,
      format: /^[a-z0-9]{2,20}$/,
      length: 2..20

    has n, :hosts
    has n, :printers, 'Printers::Printer', through: Resource 
  end

end; end

