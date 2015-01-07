require 'spec_helper'

RSpec.describe Metasploit::Cache::Architecture do
  subject(:architecture) do
    described_class.new
  end

  it_should_behave_like 'Metasploit::Cache::Architecture',
                        namespace_name: 'Metasploit::Cache' do
    let(:seed) do
      described_class.where(abbreviation: abbreviation).first
    end
  end

  context 'associations' do
    it { should have_many(:module_architectures).class_name('Metasploit::Cache::Module::Architecture').dependent(:destroy) }
    it { should have_many(:module_instances).class_name('Metasploit::Cache::Module::Instance').through(:module_architectures) }
    it { should have_many(:target_architectures).class_name('Metasploit::Cache::Module::Target::Architecture').dependent(:destroy) }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:abbreviation).of_type(:string).with_options(null: false) }
      it { should have_db_column(:bits).of_type(:integer).with_options(null: true) }
      it { should have_db_column(:endianness).of_type(:string).with_options(null: true) }
      it { should have_db_column(:family).of_type(:string).with_options(null: true) }
      it { should have_db_column(:summary).of_type(:string).with_options(null: false) }
    end

    context 'indices' do
      it { should have_db_index(:abbreviation).unique(true) }
      it { should have_db_index(:summary).unique(true) }
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

  context 'validations' do
    it { should validate_uniqueness_of(:abbreviation) }
    it { should validate_uniqueness_of(:summary) }
  end
end