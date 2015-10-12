RSpec.describe Metasploit::Cache::Module::Persister do
  let(:module_persister) {
    described_class.new
  }

  context '#persistent' do
    subject(:persistent) {
      module_persister.persistent
    }

    specify {
      expect {
        persistent
      }.to raise_error NotImplementedError
    }
  end

  context '#with_tagged_logger' do
    subject(:with_tagged_logger) {
      module_persister.send(:with_tagged_logger, record) {}
    }

    let(:record) {
      double('ActivRecord::Base instance')
    }

    specify {
      expect {
        with_tagged_logger
      }.to raise_error NotImplementedError
    }
  end
end