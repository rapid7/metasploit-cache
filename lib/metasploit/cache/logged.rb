# Modifies logger of logged for duration of the blocks.
module Metasploit::Cache::Logged
  # Changes `#logger` on `logged` for the duration of the block to `logger`.
  #
  # @param logged [#logger, #logger=]
  # @param logger [Logger]
  # @yield [logger]
  # @yieldparam logger [Logger] `logger`
  # @yieldreturn [void]
  # @return [void]
  def self.with_logger(logged, logger)
    original_logger = logged.logger

    begin
      logged.logger = logger

      yield logger
    ensure
      logged.logger = original_logger
    end
  end

  # Tags {#logger} with the given tag and then runs block {with_logger}.
  #
  # @param logged [#logger, #logger=]
  # @param logger [ActiveSupport::TaggedLogger, #tagged]
  # @yield [logger]
  # @yieldparam logger [ActiveSupport::TaggedLogger] `logger` with `tag` applied
  # @yieldreturn [void]
  # @return [void]
  def self.with_tagged_logger(logged, logger, tag, &block)
    logger.tagged(tag) do
      with_logger(logged, logger, &block)
    end
  end
end