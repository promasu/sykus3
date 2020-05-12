require 'common'

module Sykus; module Webfilter

  # Updates IP list of less-restricted webfilter users.
  class UpdateNonStudentsListJob
    extend Resque::Plugins::Queue::Lock
    extend Resque::Plugins::Workers::Lock
    @queue = :fast

    # IP list file.
    LIST_FILE = '/var/lib/sykus3/blacklists/nonstudents.list'

    # Runs the job.
    def self.perform
      iplist = {}

      Users::Session.each do |session|
        next if session.user.position_group == :student

        if session.host
          iplist[session.host.ip.to_s] = true
          next
        end

        if (session.ip && 
            session.ip > IPAddr.new('10.42.200.0') &&
            session.ip < IPAddr.new('10.42.255.254'))
          iplist[session.ip.to_s] = true
        end
      end

      File.open(LIST_FILE, 'w+') do |f|
        iplist.keys.each do |ip|
          f.write "#{ip}\n"
        end
      end

      system 'sudo squid3 -k reconfigure'
    end
  end

end; end

