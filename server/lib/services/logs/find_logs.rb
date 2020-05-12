require 'common'


module Sykus; module Logs

  # Find log entries.
  class FindLogs < ServiceBase

    # Return all service log entries.
    # @return [Array] Log data.
    def service_logs(get_since = nil)
      enforce_permission! :logs_read

      # do not return all results if diff timestamp is 0
      return [] if !get_since.nil? && get_since.to_f < 1
      get_since = 0 if get_since.nil?

      ServiceLog.all(:created_at.gte => Time.at(get_since.to_f)).map do |entry|
        data = select_entity_props(entry, [ :id, :username, :service, 
                                   :input, :output ])

        data.merge({
          created_at: entry.created_at.to_s,
        })
      end
      end

      # Return all session log entries.
      # @return [Array] Log data.
      def session_logs(get_since = nil)
        enforce_permission! :logs_read

        # do not return all results if diff timestamp is 0
        return [] if !get_since.nil? && get_since.to_f < 1
        get_since = 0 if get_since.nil?

        SessionLog.all(:created_at.gte => Time.at(get_since.to_f)).map do |entry|
          data = select_entity_props(entry, [ :id, :username, :type ])

          data.merge({
            ip: entry.ip.to_s,
            created_at: entry.created_at.to_s,
          })
        end
        end

      end

    end; end

