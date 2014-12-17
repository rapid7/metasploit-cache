require 'spec_helper'

RSpec.describe Metasploit::Model::Architecture do
  it_should_behave_like 'Metasploit::Model::Architecture',
                        namespace_name: 'Dummy' do
    let(:seed) do
      Dummy::Architecture.with_abbreviation(abbreviation)
    end
  end

  context 'sequences' do
    context 'metasploit_model_architecture_abbreviation' do
      subject(:metasploit_model_architecture_abbreviation) do
        FactoryGirl.generate :metasploit_model_architecture_abbreviation
      end

      it 'should be an element of Metasploit::Model::Architecture::ABBREVIATIONS' do
        expect(Metasploit::Model::Architecture::ABBREVIATIONS).to include(metasploit_model_architecture_abbreviation)
      end
    end

    context 'metasploit_model_architecture_bits' do
      subject(:metasploit_model_architecture_bits) do
        FactoryGirl.generate :metasploit_model_architecture_bits
      end

      it 'should be an element of Metasploit::Model::Architecture::BITS' do
        expect(Metasploit::Model::Architecture::BITS).to include(metasploit_model_architecture_bits)
      end
    end

    context 'metasploit_model_architecture_endianness' do
      subject(:metasploit_model_architecture_endianness) do
        FactoryGirl.generate :metasploit_model_architecture_endianness
      end

      it 'should be an element of Metasploit::Model::Architecture::ENDIANNESSES' do
        expect(Metasploit::Model::Architecture::ENDIANNESSES).to include(metasploit_model_architecture_endianness)
      end
    end

    context 'metasploit_model_architecture_family' do
      subject(:metasploit_model_architecture_family) do
        FactoryGirl.generate :metasploit_model_architecture_family
      end

      it 'should be an element of Metasploit::Model::Architecture::FAMILIES' do
        expect(Metasploit::Model::Architecture::FAMILIES).to include(metasploit_model_architecture_family)
      end
    end
  end
end