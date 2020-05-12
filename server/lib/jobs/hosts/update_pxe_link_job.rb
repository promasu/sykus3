require 'common'

module Sykus; module Hosts

  # Updates the PXE link for a given host.
  class UpdatePXELinkJob
    extend Resque::Plugins::Lock
    @queue = :fast

    # Link directory path.
    LINK_DIR = '/var/lib/sykus3/tftp/conf.d'

    # Runs the job.
    # @param [Integer] host_id Host ID.
    def self.perform(host_id)
      host = Host.get! host_id

      src = LINK_DIR + '/' + host.mac.gsub(':', '')
      dest = host.ready ? '../local.conf' : '../sni.conf'

      FileUtils.ln_sf dest, src
    end
  end

end; end

