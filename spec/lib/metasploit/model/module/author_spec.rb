require 'spec_helper'

RSpec.describe Metasploit::Model::Module::Author do
  it_should_behave_like 'Metasploit::Model::Module::Author',
                        namespace_name: 'Dummy'
end