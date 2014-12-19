require 'spec_helper'

RSpec.describe Metasploit::Cache::Authority do
  it_should_behave_like 'Metasploit::Cache::Authority',
                        namespace_name: 'Dummy' do
    def seed_with_abbreviation(abbreviation)
      Dummy::Authority.with_abbreviation(abbreviation)
    end
  end
end