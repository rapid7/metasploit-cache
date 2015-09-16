# Changes format to `[<date_time>][<severity>] <message>\n`
class Metasploit::Cache::CLI::LoggerFormatter < Logger::Formatter
  #
  # CONSTANTS
  #

  # Format for `<date_time>` in call
  DATETIME_FORMAT = "%Y-%m-%d %H:%M:%S.%3N".freeze

  #
  # Initialize
  #

  def initialize
    self.datetime_format = DATETIME_FORMAT
  end

  #
  # Instant Methods
  #

  def call(severity, date_time, _progname, message)
    "[#{format_datetime(date_time)}][#{severity}]#{msg2str(message)}\n"
  end
end