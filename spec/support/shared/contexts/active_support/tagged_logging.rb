shared_context 'ActiveSupport::TaggedLogging' do
  let(:logger) {
    ActiveSupport::TaggedLogging.new(
        Logger.new(logger_string_io)
    ).tap { |logger|
      logger.level = Logger::DEBUG
    }
  }

  let(:logger_string_io) {
    StringIO.new
  }
end