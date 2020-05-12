module Sykus; module Includes

  # Custom logger class with additional methods.
  class BetterLogger < Logger
    # Logs an exception with nice formatting
    # @param [String] msg Message.
    # @param [Exception] e Exception instance.
    def exception(msg, e)
      error "Exception in #{msg}: #{e}"
        error e.backtrace.join("\n") + "\n"
    end
  end

  STDOUT.sync = true
  ::Sykus::LOG = BetterLogger.new(APP_ENV == :test ? '/dev/null' : STDOUT)

end; end

