# Wraps a Logger so that it responds to API needed for `ProgressBar#output`.
class Metasploit::Cache::CLI::ProgressBarOutput
  #
  # Attributes
  #

  # @return [Logger]
  attr_reader :logger

  #
  # Initialize
  #

  # @param logger [Logger, #info]
  def initialize(logger)
    self.logger = logger
    self.buffer = ""
  end

  #
  # Instance Methods
  #

  # Writes {#buffer} to {#logger} as INFO, then resets {#buffer}.
  #
  # @return [void]
  def flush
    logger.info(buffer)
    buffer.clear
  end

  # @note Call {#flush} to log string as INFO to {#logger}.
  #
  # Buffer string until {#flush} is called.
  #
  # @param string [String] message to log.  Blank strings and "\r" are ignored.
  # @return [void]
  # @see #flush
  def print(string)
    # ignore the `ProgressBar::Outputs::Tty#clear` because we're not really a tty
    unless string.blank? || string == "\r"
      buffer << string
    end
  end

  # Pretend to be a TTY so that full Ruby ProgressBar features are used, including that want to rewrite screen.
  #
  # @return [true]
  def tty?
    true
  end

  private

  # @return [String]
  attr_accessor :buffer
  attr_writer :logger
end