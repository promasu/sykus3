require 'common'

require 'jobs/common/demodata_job'

module Sykus; module Api

  class App
    post '/demodata/' do
      exception_wrapper do
        unless Config::ConfigValue.get('demo')
          raise Exceptions::Input, 'Not in demo mode'
        end

        cmd = '/usr/lib/sykus3/server/sykus-tool demo --yes-please'
        system "echo \"#{cmd}\" |sudo at now"
      end
    end
  end

end; end

