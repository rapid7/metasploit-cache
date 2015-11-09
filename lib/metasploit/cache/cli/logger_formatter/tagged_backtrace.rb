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
  # @param date_time [DateTime] when this message occured
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

  # Whether to accept the message for formating or return an empty string from {#call}.
  #
  # @param message [Object]
  # @return [true] if `message` is not a `String` or `message` is a `String`, but does not begin with
  #   {SQLITE#_BINARY_DATA_PREFIX}.
  # @return [false] if `message` is a `String` and it begins with {SQLITE3_BINARY_DATA_PREFIX}
  def accept(message)
    !message.is_a?(String) || !message.start_with?(SQLITE3_BINARY_DATA_PREFIX)
  end

  # Converts `message` to a `String`.
  #
  # @param message [Object]
  # @return [String]
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

  # Whetherto reject the line from the exception backtrace.
  #
  # @return [false] if `line` starts with `Dir.pwd`
  # @return [true] otherwise
  def reject_backtrace_line(line)
    !line.start_with?(Dir.pwd)
  end
end