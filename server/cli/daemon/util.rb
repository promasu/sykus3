require 'shellwords'

module Util
  def self.server_domain
    @server_domain ||= File.read('server_domain').strip
  end

  def self.userdo(cmd)
    %x{DISPLAY=:0 su - #{Session.user[:username]} -c "#{cmd}"}
  end
end

