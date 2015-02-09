require 'spec_helper'

RSpec.describe Metasploit::Cache::Module::Action do
  it_should_behave_like 'Metasploit::Cache::Module::Action',
                        namespace_name: 'Dummy'
end