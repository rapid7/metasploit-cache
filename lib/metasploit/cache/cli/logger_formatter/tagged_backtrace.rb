# Overrides `#call` from `ActiveSupport::TaggedLogging::Formatter` so that exceptions will print their backtraces like
# `Logger::Formatter` from the standard library.
module Metasploit::Cache::CLI::LoggerFormatter::TaggedBacktrace
  # Converts the message to a string using `Logger::Formatter#msg2str` so exceptions include their backtraces.
  #
  # @param severity [String] severity level
  # @param data_time [DateTime] when this message occured
  # @param _progname [String] Ignored
  # @param message [String, Exception, #inspect] Logger message, exception that was raised, or object to inspect
  # @return [void]
  def call(severity, date_time, _progname, message)
    "[#{format_datetime(date_time)}][#{severity}]#{tags_text} #{msg2str(message)}\n"
  end
end