require 'spec_helper'

RSpec.describe Metasploit::Cache::Module::Rank do
  it_should_behave_like 'Metasploit::Cache::Module::Rank',
                        namespace_name: 'Dummy'

  # Not in 'Metasploit::Cache::Module::Rank' shared example since sequence should not be overridden in namespaces.
  context 'sequences' do
    context 'metasploit_cache_module_rank_name' do
      subject(:metasploit_cache_module_rank_name) do
        FactoryGirl.generate :metasploit_cache_module_rank_name
      end

      it 'should be key in Metasploit::Cache::Module::Rank::NUMBER_BY_NAME' do
        expect(Metasploit::Cache::Module::Rank::NUMBER_BY_NAME).to have_key(metasploit_cache_module_rank_name)
      end
    end

    context 'metasploit_cache_module_rank_number' do
      subject(:metasploit_cache_module_rank_number) do
        FactoryGirl.generate :metasploit_cache_module_rank_number
      end

      it 'should be value in Metasploit::Cache::Module::Rank::NUMBER_BY_NAME' do
        expect(Metasploit::Cache::Module::Rank::NUMBER_BY_NAME).to have_value(metasploit_cache_module_rank_number)
      end
    end
  end
end