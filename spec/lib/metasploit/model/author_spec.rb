require 'spec_helper'

RSpec.describe Metasploit::Model::Author do
  it_should_behave_like 'Metasploit::Model::Author',
                        namespace_name: 'Dummy'
end