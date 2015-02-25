shared_examples_for 'Metasploit::Cache::Module::Ancestor payload factory' do
  it 'is a payload' do
    expect(subject.module_type).to eq('payload')
  end

  context 'contents' do
    include_context 'Metasploit::Cache::Module::Ancestor factory contents'

    context 'metasploit_module' do
      include_context 'Metasploit::Cache::Module::Ancestor factory contents metasploit_module'

      it { should be_a Module }
      it { should_not be_a Class }
    end
  end
end