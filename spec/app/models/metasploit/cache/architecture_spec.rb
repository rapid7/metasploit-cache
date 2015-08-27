RSpec.describe Metasploit::Cache::Architecture do
  subject(:architecture) do
    described_class.new
  end

  context 'CONSTANTS' do
    context 'ABBREVIATIONS' do
      subject(:abbreviations) do
        described_class::ABBREVIATIONS
      end

      it 'should be an Array<String>' do
        expect(abbreviations).to be_an Array

        abbreviations.each do |architecture|
          expect(architecture).to be_a String
        end
      end

      it 'should include both endians of ARM' do
        expect(abbreviations).to include('armbe')
        expect(abbreviations).to include('armle')
      end

      it 'should include 32-bit and 64-bit versions of Cell Broadband Engine Architecture' do
        expect(abbreviations).to include('cbea')
        expect(abbreviations).to include('cbea64')
      end

      it 'should include cmd for command shell' do
        expect(abbreviations).to include('cmd')
      end

      it 'should include dalvik for Dalvik Virtual Machine in Google Android' do
        expect(abbreviations).to include('dalvik')
      end

      it 'should include firefox for Firefox privileged javascript API' do
        expect(abbreviations).to include('firefox')
      end

      it 'should include java for Java Virtual Machine' do
        expect(abbreviations).to include('java')
      end

      it 'should include endian-ware MIPS' do
        expect(abbreviations).to include('mipsbe')
        expect(abbreviations).to include('mipsle')
      end

      it 'should include nodejs for javascript code that requires NodeJS extensions/libraries' do
        expect(abbreviations).to include('nodejs')
      end

      it 'should include php for PHP code' do
        expect(abbreviations).to include('php')
      end

      it 'should include 32-bit and 64-bit PowerPC' do
        expect(abbreviations).to include('ppc')
        expect(abbreviations).to include('ppc64')
      end

      it 'should include python for Python code' do
        expect(abbreviations).to include('python')
      end

      it 'should include ruby for Ruby code' do
        expect(abbreviations).to include('ruby')
      end

      it 'should include sparc for Sparc' do
        expect(abbreviations).to include('sparc')
      end

      it 'should include tty for Terminals' do
        expect(abbreviations).to include('tty')
      end

      it 'should include 32-bit and 64-bit x86' do
        expect(abbreviations).to include('x86')
        expect(abbreviations).to include('x86_64')
      end
    end

    context 'BITS' do
      subject(:bits) do
        described_class::BITS
      end

      it { should include 32 }
      it { should include 64 }
    end

    context 'ENDIANNESSES' do
      subject(:endiannesses) do
        described_class::ENDIANNESSES
      end

      it { should include 'big' }
      it { should include 'little' }
    end

    context 'FAMILIES' do
      subject(:families) do
        described_class::FAMILIES
      end

      it 'includes arm for big- and little-endian ARM' do
        expect(families).to include('arm')
      end

      it 'includes cbea for 32- and 64-bit Cell Broadband Engine Architecture' do
        expect(families).to include('cbea')
      end

      it 'includes javascript for NodeJS' do
        expect(families).to include('javascript')
      end

      it 'includes mips for big and little-endian MIPS' do
        expect(families).to include('mips')
      end

      it 'includes ppc for 32- and 64-bit PPC' do
        expect(families).to include('ppc')
      end

      it 'includes sparc for sparc' do
        expect(families).to include('sparc')
      end

      it 'includes x86 for x86 and x86_64' do
        expect(families).to include('x86')
      end
    end
  end

  context 'associations' do
    it { is_expected.to have_many(:architecturable_architectures).class_name('Metasploit::Cache::Architecturable::Architecture').dependent(:destroy).inverse_of(:architecture) }
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

  context 'search' do
    let(:base_class) {
      Metasploit::Cache::Architecture
    }

    context 'attributes' do
      it_should_behave_like 'search_attribute',
                            :abbreviation,
                            type: {
                                set: :string
                            }
      it_should_behave_like 'search_attribute',
                            :bits,
                            type: {
                                set: :integer
                            }
      it_should_behave_like 'search_attribute',
                            :endianness,
                            type: {
                                set: :string
                            }
      it_should_behave_like 'search_attribute',
                            :family,
                            type: {
                                set: :string
                            }
    end
  end

  context 'seeds' do
    it_should_behave_like 'Metasploit::Cache::Architecture seed',
                          :abbreviation => 'armbe',
                          :bits => 32,
                          :endianness => 'big',
                          :family => 'arm',
                          :summary => 'Little-endian ARM'

    it_should_behave_like 'Metasploit::Cache::Architecture seed',
                          :abbreviation => 'armle',
                          :bits => 32,
                          :endianness => 'little',
                          :family => 'arm',
                          :summary => 'Big-endian ARM'

    it_should_behave_like 'Metasploit::Cache::Architecture seed',
                          :abbreviation => 'cbea',
                          :bits => 32,
                          :endianness => 'big',
                          :family => 'cbea',
                          :summary => '32-bit Cell Broadband Engine Architecture'

    it_should_behave_like 'Metasploit::Cache::Architecture seed',
                          :abbreviation => 'cbea64',
                          :bits => 64,
                          :endianness => 'big',
                          :family => 'cbea',
                          :summary => '64-bit Cell Broadband Engine Architecture'

    it_should_behave_like 'Metasploit::Cache::Architecture seed',
                          :abbreviation => 'cmd',
                          :bits => nil,
                          :endianness => nil,
                          :family => nil,
                          :summary => 'Command Injection'

    it_should_behave_like 'Metasploit::Cache::Architecture seed',
                          :abbreviation => 'dalvik',
                          :bits => nil,
                          :endianness => nil,
                          :family => nil,
                          :summary => 'Dalvik process virtual machine used in Google Android'

    it_should_behave_like 'Metasploit::Cache::Architecture seed',
                          abbreviation: 'firefox',
                          bits: nil,
                          endianness: nil,
                          family: 'javascript',
                          summary: "Firefox's privileged javascript API"

    it_should_behave_like 'Metasploit::Cache::Architecture seed',
                          :abbreviation => 'java',
                          :bits => nil,
                          :endianness => 'big',
                          :family => nil,
                          :summary => 'Java'

    it_should_behave_like 'Metasploit::Cache::Architecture seed',
                          :abbreviation => 'mipsbe',
                          :bits => 32,
                          :endianness => 'big',
                          :family => 'mips',
                          :summary => 'Big-endian MIPS'

    it_should_behave_like 'Metasploit::Cache::Architecture seed',
                          :abbreviation => 'mipsle',
                          :bits => 32,
                          :endianness => 'little',
                          :family => 'mips',
                          :summary => 'Little-endian MIPS'

    it_should_behave_like 'Metasploit::Cache::Architecture seed',
                          :abbreviation => 'nodejs',
                          :bits => nil,
                          :endianness => nil,
                          :family => 'javascript',
                          :summary => 'NodeJS'

    it_should_behave_like 'Metasploit::Cache::Architecture seed',
                          :abbreviation => 'php',
                          :bits => nil,
                          :endianness => nil,
                          :family => nil,
                          :summary => 'PHP'

    it_should_behave_like 'Metasploit::Cache::Architecture seed',
                          :abbreviation => 'ppc',
                          :bits => 32,
                          :endianness => 'big',
                          :family => 'ppc',
                          :summary => '32-bit Peformance Optimization With Enhanced RISC - Performance Computing'

    it_should_behave_like 'Metasploit::Cache::Architecture seed',
                          :abbreviation => 'ppc64',
                          :bits => 64,
                          :endianness => 'big',
                          :family => 'ppc',
                          :summary => '64-bit Performance Optimization With Enhanced RISC - Performance Computing'

    it_should_behave_like 'Metasploit::Cache::Architecture seed',
                          :abbreviation => 'python',
                          :bits => nil,
                          :endianness => nil,
                          :family => nil,
                          :summary => 'Python'

    it_should_behave_like 'Metasploit::Cache::Architecture seed',
                          :abbreviation => 'ruby',
                          :bits => nil,
                          :endianness => nil,
                          :family => nil,
                          :summary => 'Ruby'

    it_should_behave_like 'Metasploit::Cache::Architecture seed',
                          :abbreviation => 'sparc',
                          :bits => nil,
                          :endianness => nil,
                          :family => 'sparc',
                          :summary => 'Scalable Processor ARChitecture'

    it_should_behave_like 'Metasploit::Cache::Architecture seed',
                          :abbreviation => 'tty',
                          :bits => nil,
                          :endianness => nil,
                          :family => nil,
                          :summary => '*nix terminal'

    it_should_behave_like 'Metasploit::Cache::Architecture seed',
                          :abbreviation => 'x86',
                          :bits => 32,
                          :endianness => 'little',
                          :family => 'x86',
                          :summary => '32-bit x86'

    it_should_behave_like 'Metasploit::Cache::Architecture seed',
                          :abbreviation => 'x86_64',
                          :bits => 64,
                          :endianness => 'little',
                          :family => 'x86',
                          :summary => '64-bit x86'
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
    context 'abbreviation' do
      # have to test inclusion validation manually because
      # validate_inclusion_of(:abbreviation).in_array(described_class::ABBREVIATIONS).allow_nil does not work with
      # additional uniqueness validation.
      context 'ensure inclusion of abbreviation in ABBREVIATIONS' do
        let(:error) do
          'is not included in the list'
        end

        abbreviations = [
            'armbe',
            'armle',
            'cbea',
            'cbea64',
            'cmd',
            'dalvik',
            'firefox',
            'java',
            'mipsbe',
            'mipsle',
            'nodejs',
            'php',
            'ppc',
            'ppc64',
            'python',
            'ruby',
            'sparc',
            'tty',
            'x86',
            'x86_64'
        ]

        abbreviations.each do |abbreviation|
          context "with #{abbreviation.inspect}" do
            before(:each) do
              architecture.abbreviation = abbreviation

              architecture.valid?
            end

            it 'should not record error on abbreviation' do
              expect(architecture.errors[:abbreviation]).not_to include(error)
            end
          end
        end
      end
    end

    it { should validate_uniqueness_of(:abbreviation) }
    it { should validate_inclusion_of(:bits).in_array(described_class::BITS).allow_nil }
    it { should validate_inclusion_of(:endianness).in_array(described_class::ENDIANNESSES).allow_nil }
    it { should validate_inclusion_of(:family).in_array(described_class::FAMILIES).allow_nil }
    it { should validate_presence_of(:summary) }
    it { should validate_uniqueness_of(:summary) }
  end

  context 'abbreviation_set' do
    subject(:abbreviation_set) do
      described_class.abbreviation_set
    end

    it { should_not include nil }
    it { should include 'armbe' }
    it { should include 'armle' }
    it { should include 'cbea' }
    it { should include 'cbea64' }
    it { should include 'cmd' }
    it { should include 'dalvik' }
    it { should include 'firefox' }
    it { should include 'java' }
    it { should include 'mipsbe' }
    it { should include 'mipsle' }
    it { should include 'nodejs' }
    it { should include 'php' }
    it { should include 'ppc' }
    it { should include 'ppc64' }
    it { should include 'python' }
    it { should include 'ruby' }
    it { should include 'sparc' }
    it { should include 'tty' }
    it { should include 'x86' }
    it { should include 'x86_64' }
  end

  context 'bits_set' do
    subject(:bits_set) do
      described_class.bits_set
    end

    it { should_not include nil }
    it { should include 32 }
    it { should include 64 }
  end

  context 'endianness_set' do
    subject(:endianness_set) do
      described_class.endianness_set
    end

    it { should_not include nil }
    it { should include 'big' }
    it { should include 'little' }
  end

  context 'family_set' do
    subject(:family_set) do
      described_class.family_set
    end

    it { should_not include nil }
    it { should include 'arm' }
    it { should include 'cbea' }
    it { should include 'mips' }
    it { should include 'javascript' }
    it { should include 'ppc' }
    it { should include 'sparc' }
    it { should include 'x86' }
  end
end