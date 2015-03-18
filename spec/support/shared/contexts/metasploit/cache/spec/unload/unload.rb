# Use in a context to clean up the constants that are created by the module loader.
shared_context 'Metasploit::Cache::Spec::Unload.unload' do
  after(:each) do
    Metasploit::Cache::Spec::Unload.unload
  end
end