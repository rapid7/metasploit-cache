require 'spec_helper'

RSpec.describe Metasploit::Cache::Module::Path do
  it_should_behave_like 'Metasploit::Cache::Module::Path',
                        namespace_name: 'Dummy'
end