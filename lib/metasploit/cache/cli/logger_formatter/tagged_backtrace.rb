# Overrides `#call` from `ActiveSupport::TaggedLogging::Formatter` so that exceptions will print their backtraces like
# `Logger::Formatter` from the standard library.
module Metasploit::Cache::CLI::LoggerFormatter::TaggedBacktrace
  #
  # CONSTANTS
  #

  SQLITE3_BINARY_DATA_PREFIX = 'Binary data inserted for `string` type on column'

  #
  # Instance Methods
  #

  # Converts the message to a string using `Logger::Formatter#msg2str` so exceptions include their backtraces.
  #
  # @param severity [String] severity level
  # @param data_time [DateTime] when this message occured
  # @param _progname [String] Ignored
  # @param message [String, Exception, #inspect] Logger message, exception that was raised, or object to inspect
  # @return [void]
  def call(severity, date_time, _progname, message)
    if accept(message)
      "[#{format_datetime(date_time)}][#{severity}]#{tags_text} #{msg2str(message)}\n"
    else
      ''
    end
  end

  private

  def accept(message)
    !message.is_a?(String) || !message.start_with?(SQLITE3_BINARY_DATA_PREFIX)
  end

  def msg2str(message)
    case message
    when ::Exception
      lines = ["#{message.message} (#{message.class})"]

      message.backtrace.each do |line|
        unless reject_backtrace_line(line)
          lines << line
        end
      end

      lines.join("\n")
    else
      super
    end
  end

  def reject_backtrace_line(line)
    !line.start_with?(Dir.pwd)
  end
end