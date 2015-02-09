require 'spec_helper'

RSpec.describe Metasploit::Cache::Module::Author do
  it_should_behave_like 'Metasploit::Cache::Module::Author',
                        namespace_name: 'Dummy'
end