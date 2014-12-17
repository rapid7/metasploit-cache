require 'spec_helper'

RSpec.describe Metasploit::Model::Module::Reference,
         # setting the metadata type makes rspec-rails include RSpec::Rails::ModelExampleGroup, which includes a better
         # be_valid matcher that will print full error messages
         type: :model do
  it_should_behave_like 'Metasploit::Model::Module::Reference',
                        namespace_name: 'Dummy'
end