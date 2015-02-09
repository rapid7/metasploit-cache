require 'spec_helper'

RSpec.describe Metasploit::Cache::Module::Architecture,
         # setting the metadata type makes rspec-rails include RSpec::Rails::ModelExampleGroup, which includes a better
         # be_valid matcher that will print full error messages
         type: :model do
  it_should_behave_like 'Metasploit::Cache::Module::Architecture',
                        namespace_name: 'Dummy'
end