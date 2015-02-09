require 'spec_helper'

RSpec.describe Metasploit::Cache::Architecture do
  it_should_behave_like 'Metasploit::Cache::Architecture',
                        namespace_name: 'Dummy' do
    let(:seed) do
      Dummy::Architecture.with_abbreviation(abbreviation)
    end
  end

  context 'sequences' do
    context 'metasploit_cache_architecture_abbreviation' do
      subject(:metasploit_cache_architecture_abbreviation) do
        FactoryGirl.generate :metasploit_cache_architecture_abbreviation
      end

      it 'should be an element of Metasploit::Cache::Architecture::ABBREVIATIONS' do
        expect(Metasploit::Cache::Architecture::ABBREVIATIONS).to include(metasploit_cache_architecture_abbreviation)
      end
    end

    context 'metasploit_cache_architecture_bits' do
      subject(:metasploit_cache_architecture_bits) do
        FactoryGirl.generate :metasploit_cache_architecture_bits
      end

      it 'should be an element of Metasploit::Cache::Architecture::BITS' do
        expect(Metasploit::Cache::Architecture::BITS).to include(metasploit_cache_architecture_bits)
      end
    end

    context 'metasploit_cache_architecture_endianness' do
      subject(:metasploit_cache_architecture_endianness) do
        FactoryGirl.generate :metasploit_cache_architecture_endianness
      end

      it 'should be an element of Metasploit::Cache::Architecture::ENDIANNESSES' do
        expect(Metasploit::Cache::Architecture::ENDIANNESSES).to include(metasploit_cache_architecture_endianness)
      end
    end

    context 'metasploit_cache_architecture_family' do
      subject(:metasploit_cache_architecture_family) do
        FactoryGirl.generate :metasploit_cache_architecture_family
      end

      it 'should be an element of Metasploit::Cache::Architecture::FAMILIES' do
        expect(Metasploit::Cache::Architecture::FAMILIES).to include(metasploit_cache_architecture_family)
      end
    end
  end
end