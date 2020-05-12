require 'common'

module Sykus; module Printers

  # Reads available printer drivers and stores them for fast access.
  class ReadDriversJob
    extend Resque::Plugins::Lock
    @queue = :slow

    # Runs the job.
    def self.perform
      result = `sudo lpinfo -m`.strip

      drivers = []
      result.split("\n").each do |line|
        words = line.strip.split(' ')
        id = words.shift
        name = words.join(' ')

        drivers << { id: id, name: name }
      end

      drivers.uniq! { |d| d[:name] }

      REDIS.set 'Printers.drivers', drivers.to_json
    end
  end

end; end

