RSpec.shared_examples_for 'Metasploit::Cache::Module::Ancestor factory' do |persister_class:|
  it { is_expected.to be_valid }

  it_should_behave_like 'Metasploit::Cache::Module::Ancestor factory loading',
                        persister_class: persister_class

  context 'contents' do
    include_context 'Metasploit::Cache::Module::Ancestor factory contents'

    context 'metasploit_module' do
      include_context 'Metasploit::Cache::Module::Ancestor factory contents metasploit_module'

      it { should be_a Class }
    end
  end
end