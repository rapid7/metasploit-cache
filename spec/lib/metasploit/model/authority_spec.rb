require 'spec_helper'

RSpec.describe Metasploit::Model::Authority do
  it_should_behave_like 'Metasploit::Model::Authority',
                        namespace_name: 'Dummy' do
    def seed_with_abbreviation(abbreviation)
      Dummy::Authority.with_abbreviation(abbreviation)
    end
  end
end