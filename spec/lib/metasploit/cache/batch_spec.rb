require 'spec_helper'

RSpec.describe Metasploit::Cache::Batch do
  context 'CONSTANTS' do
    context 'THREAD_LOCAL_VARIABLE_NAME' do
      subject(:thread_local_variable_name) do
        described_class::THREAD_LOCAL_VARIABLE_NAME
      end

      it { is_expected.to eq(:metasploit_cache_batch) }
    end
  end

  context 'batch' do
    def batch(&block)
      described_class.batch(&block)
    end

    around(:each) do |example|
      before = Thread.current[:metasploit_cache_batch]

      example.run

      Thread.current[:metasploit_cache_batch] = before
    end

    context 'inside block' do
      it 'should have batched? true' do
        batch do
          expect(described_class).to be_batched
        end
      end

      context 'with error' do
        it 'should restore thread local variable' do
          before = double('before')
          Thread.current[described_class::THREAD_LOCAL_VARIABLE_NAME] = before

          expect {
            batch do
              raise
            end
          }.to raise_error

          expect(Thread.current[described_class::THREAD_LOCAL_VARIABLE_NAME]).to eq(before)
        end
      end

      context 'without error' do
        it 'should restore thread local variable' do
          before = double('before')
          Thread.current[described_class::THREAD_LOCAL_VARIABLE_NAME] = before

          expect {
            batch {}
          }.to_not raise_error

          expect(Thread.current[described_class::THREAD_LOCAL_VARIABLE_NAME]).to eq(before)
        end
      end
    end
  end

  context 'batched?' do
    subject(:batched?) do
      described_class.batched?
    end

    context 'without calling batch' do
      it { is_expected.to eq(false) }

      it 'should convert thread local variable to boolean' do
        expect(Thread.current[described_class::THREAD_LOCAL_VARIABLE_NAME]).not_to eq(false)
      end
    end
  end
end