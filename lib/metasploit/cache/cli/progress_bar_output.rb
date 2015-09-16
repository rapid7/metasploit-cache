# Wraps a Logger so that it responds to API needed for `ProgressBar#output`.
class Metasploit::Cache::CLI::ProgressBarOutput
  #
  # Attributes
  #

  attr_reader :logger

  #
  # Initialize
  #

  def initialize(logger)
    self.logger = logger
    self.buffer = ""
  end

  #
  # Instance Methods
  #

  def flush
    logger.info(buffer)
    buffer.clear
  end

  def print(string)
    # ignore the `ProgressBar::Outputs::Tty#clear` because we're not really a tty
    unless string.blank? || string == "\r"
      buffer << string
    end
  end

  def tty?
    true
  end

  private

  attr_accessor :buffer
  attr_writer :logger
end