RSpec.describe Metasploit::Cache::Auxiliary::Ancestor do
  it_should_behave_like 'Metasploit::Cache::Module::Ancestor.restrict', module_type: 'auxiliary', module_type_directory: 'auxiliary'
  it_should_behave_like 'Metasploit::Concern.run'
end