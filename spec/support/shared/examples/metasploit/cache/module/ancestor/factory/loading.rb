RSpec.shared_examples_for 'Metasploit::Cache::Module::Ancestor factory loading' do |persister_class:|
  include_context 'Metasploit::Cache::Spec::Unload.unload'

  context 'Metasploit::Cache::Module::Ancestor::Load' do
    include_context 'ActiveSupport::TaggedLogging'

    subject(:module_ancestor_load) {
      Metasploit::Cache::Module::Ancestor::Load.new(
          logger: logger,
          maximum_version: 4,
          module_ancestor: module_ancestor,
          persister_class: persister_class
      )
    }

    it { is_expected.to be_valid }

    specify {
      expect {
        module_ancestor_load.valid?
      }.to change(described_class, :count).from(0).to(1)
    }
  end
end
