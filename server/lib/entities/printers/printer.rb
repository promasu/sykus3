module Sykus; module Printers

  # Entity representing a hardware printer.
  class Printer
    include DataMapper::Resource

    property :id, Serial, 
      max: 1e10,
      writer: :private

    property :name, String, 
      required: true,
      unique: true,
      length: 3..30

    property :url, String, 
      required: true,
      unique: true,
      length: 255

    property :driver, String,
      required: true,
      length: 255

    has n, :host_groups, 'Hosts::HostGroup', through: Resource
  end

end; end

