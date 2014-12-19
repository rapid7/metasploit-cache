shared_examples_for 'Metasploit::Cache::Module::Handler' do
  it { should be_a Module }

  context 'general_handler_type' do
    subject(:general_handler_type) do
      handler_module.general_handler_type
    end

    it 'should be in Metasploit::Cache::Module::Handler::GENERAL_TYPES' do
      expect(general_handler_type).to be_in Metasploit::Cache::Module::Handler::GENERAL_TYPES
    end
  end

  context 'handler_type' do
    subject(:handler_type) do
      handler_module.handler_type
    end

    it { should be_a String }
  end
end