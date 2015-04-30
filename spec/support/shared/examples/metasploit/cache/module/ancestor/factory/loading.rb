RSpec.shared_examples_for 'Metasploit::Cache::Module::Ancestor factory loading' do
  include_context 'Metasploit::Cache::Spec::Unload.unload'

  context 'Metasploit::Cache::Module::Ancestor::Load' do
    subject(:module_ancestor_load) {
      Metasploit::Cache::Module::Ancestor::Load.new(
          logger: logger,
          maximum_version: 4,
          module_ancestor: module_ancestor
      )
    }

    let(:logger) {
      ActiveSupport::TaggedLogging.new(
          Logger.new(string_io)
      )
    }

    let(:string_io) {
      StringIO.new
    }

    it { is_expected.to be_valid }

    specify {
      expect {
        module_ancestor_load.valid?
      }.to change(described_class, :count).from(0).to(1)
    }
  end
end
