require 'spec_helper'

RSpec.describe Metasploit::Cache::Module::Ancestor do
  it_should_behave_like 'Metasploit::Cache::Module::Ancestor',
                        namespace_name: 'Dummy'
end