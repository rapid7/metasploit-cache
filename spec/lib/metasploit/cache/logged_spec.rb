RSpec.describe Metasploit::Cache::Logged do
  include_context 'ActiveSupport::TaggedLogging'

  let(:original_logger) {
    double('Original Logger')
  }

  let(:logged) {
    OpenStruct.new(logger: original_logger)
  }

  context 'with_logger' do
    def with_logger(&block)
      described_class.with_logger(logged, logger, &block)
    end

    context 'in block' do
      it 'changes logged.logger to passed logger' do
        expect(logged.logger).to eq(original_logger)

        with_logger do
          expect(logged.logger).to eq(logger)
        end
      end

      it 'yields logger' do
        with_logger do |block_logger|
          expect(block_logger).to eq(logger)
        end
      end
    end

    context 'after block' do
      context 'with exception' do
        it 'restores original logged.logger' do
          expect {
            with_logger do
              raise Exception
            end
          }.to raise_error

          expect(logged.logger).to eq(original_logger)
        end
      end

      context 'without exception' do
        it 'restores original logged.logger' do
          expect {
            with_logger do
            end
          }.not_to raise_error

          expect(logged.logger).to eq(original_logger)
        end
      end
    end
  end

  context 'with_tagged_logger' do
    def with_tagged_logger(&block)
      described_class.with_tagged_logger(logged, logger, tag, &block)
    end

    let(:tag) {
      'some/path.rb'
    }

    context 'in block' do
      it 'tags log' do
        with_tagged_logger do
          logged.logger.error('Tagged Error')
        end

        expect(logger_string_io.string).to eq("[#{tag}] Tagged Error\n")
      end

      it 'yields logger' do
        with_tagged_logger do |block_logger|
          expect(block_logger).to eq(logger)
        end
      end
    end

    context 'after block' do
      context 'with exception' do
        it 'restores original logged.logger' do
          expect {
            with_tagged_logger do
              raise Exception
            end
          }.to raise_error

          expect(logged.logger).to eq(original_logger)
        end
      end

      context 'without exception' do
        it 'restores original logged.logger' do
          expect {
            with_tagged_logger do
            end
          }.not_to raise_error

          expect(logged.logger).to eq(original_logger)
        end
      end
    end
  end
end