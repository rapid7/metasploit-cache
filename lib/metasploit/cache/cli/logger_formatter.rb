# Changes format to `[<date_time>][<severity>] <message>\n`
class Metasploit::Cache::CLI::LoggerFormatter < Logger::Formatter
  extend ActiveSupport::Autoload

  autoload :TaggedBacktrace

  extend Metasploit::Cache::CLI::LoggerFormatter::TaggedBacktrace

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
end