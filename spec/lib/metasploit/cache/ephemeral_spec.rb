RSpec.describe Metasploit::Cache::Ephemeral do
  context 'with_connection_transaction' do
    subject(:with_connection_transaction) {
      described_class.with_connection_transaction(destination_class: destination_class, &block)
    }

    let(:block) {
      ->(){
        block_yield_return
      }
    }

    let(:block_yield_return) {
      double('block yield return')
    }

    let(:connection_pool) {
      double('Connection Pool')
    }

    let(:destination_class) {
      double('Destination Class')
    }

    it 'runs a transaction inside connection_pool.with_connection and returns block yieldreturn' do
      expect(destination_class).to receive(:connection_pool).and_return(connection_pool).ordered
      expect(connection_pool).to receive(:with_connection) { |&with_connection_block|
                                   expect(destination_class).to receive(:transaction) { |&transaction_block|
                                                                  expect(transaction_block).to eq(block)

                                                                  block.call
                                                                }

                                   with_connection_block.call
                                 }

      expect(with_connection_transaction).to eq(block_yield_return)
    end
  end
end