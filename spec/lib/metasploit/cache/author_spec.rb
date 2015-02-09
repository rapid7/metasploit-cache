require 'spec_helper'

RSpec.describe Metasploit::Cache::Author do
  it_should_behave_like 'Metasploit::Cache::Author',
                        namespace_name: 'Dummy'
end