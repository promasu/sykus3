require 'common'


require 'services/logs/find_logs'

module Sykus; module Api

  class App
    get '/logs/session/' do
      exception_wrapper do
        Logs::FindLogs.new(get_identity).session_logs.to_json
      end
    end

    get %r{^/logs/session/diff/(-?\d+\.?\d*)$} do |timestamp|
      exception_wrapper do
        {
          deleted: [],
          timestamp: Time.now.to_f,
          updated: Logs::FindLogs.new(get_identity).session_logs(timestamp)
        }.to_json
      end
    end

    get '/logs/service/' do
      exception_wrapper do
        Logs::FindLogs.new(get_identity).service_logs.to_json
      end
    end

    get %r{^/logs/service/diff/(-?\d+\.?\d*)$} do |timestamp|
      exception_wrapper do
        {
          deleted: [],
          timestamp: Time.now.to_f,
          updated: Logs::FindLogs.new(get_identity).service_logs(timestamp)
        }.to_json
      end
    end
  end

end; end

