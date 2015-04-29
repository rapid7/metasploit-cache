RSpec.describe Metasploit::Cache::Module::Rank do
  subject(:module_rank) {
    described_class.new
  }

  context 'associations' do
    it { is_expected.to have_many(:auxiliary_classes).class_name('Metasploit::Cache::Auxiliary::Class').dependent(:destroy) }
    it { is_expected.to have_many(:encoder_classes).class_name('Metasploit::Cache::Encoder::Class').dependent(:destroy) }
    it { is_expected.to have_many(:exploit_classes).class_name('Metasploit::Cache::Exploit::Class').dependent(:destroy) }
    it { should have_many(:module_classes).class_name('Metasploit::Cache::Module::Class').dependent(:destroy) }
    it { is_expected.to have_many(:nop_classes).class_name('Metasploit::Cache::Nop::Class').dependent(:destroy) }
    it { is_expected.to have_many(:post_classes).class_name('Metasploit::Cache::Post::Class').dependent(:destroy) }
    it { is_expected.to have_many(:single_payload_classes).class_name('Metasploit::Cache::Payload::Single::Class').dependent(:destroy) }
  end

  context 'CONSTANTS' do
    context 'NAME_BY_NUMBER' do
      subject(:name_by_number) do
        described_class::NAME_BY_NUMBER
      end

      it "maps 0 to 'Manual'" do
        expect(name_by_number[0]).to eq('Manual')
      end

      it "maps 100 to 'Low'" do
        expect(name_by_number[100]).to eq('Low')
      end

      it "maps 200 to 'Average'" do
        expect(name_by_number[200]).to eq('Average')
      end

      it "maps 300 to 'Normal'" do
        expect(name_by_number[300]).to eq('Normal')
      end

      it "maps 400 to 'Good'" do
        expect(name_by_number[400]).to eq('Good')
      end

      it "maps 500 to 'Great'" do
        expect(name_by_number[500]).to eq('Great')
      end

      it "maps 600 to 'Excellent'" do
        expect(name_by_number[600]).to eq('Excellent')
      end
    end

    context 'NAME_REGEXP' do
      subject(:name_regexp) do
        described_class::NAME_REGEXP
      end

      it 'should not match a #name starting with a lowercase letter' do
        expect(name_regexp).not_to match('good')
      end

      it 'should match a #name starting with a capital letter' do
        expect(name_regexp).to match('Good')
      end

      it 'should not match a #name with a space' do
        expect(name_regexp).not_to match('Super Effective')
      end
    end

    context 'NUMBER_BY_NAME' do
      subject(:number_by_name) do
        described_class::NUMBER_BY_NAME
      end

      it "maps 'Manual' to 0" do
        expect(number_by_name['Manual']).to eq(0)
      end

      it "maps 'Low' to 100" do
        expect(number_by_name['Low']).to eq(100)
      end

      it "maps 'Average' to 200" do
        expect(number_by_name['Average']).to eq(200)
      end

      it "maps 'Normal' to 300" do
        expect(number_by_name['Normal']).to eq(300)
      end

      it "maps 'Good' to 400" do
        expect(number_by_name['Good']).to eq(400)
      end

      it "maps 'Great' to 500" do
        expect(number_by_name['Great']).to eq(500)
      end

      it "maps 'Excellent' to 600" do
        expect(number_by_name['Excellent']).to eq(600)
      end
    end
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:name).of_type(:string).with_options(:null => false) }
      it { should have_db_column(:number).of_type(:integer).with_options(:null => false) }
    end

    context 'indices' do
      it { should have_db_index(:name).unique(true) }
      it { should have_db_index(:number).unique(true) }
    end
  end

  context 'sequences' do
    context 'metasploit_cache_module_rank' do
      subject(:metasploit_cache_module_rank) {
        FactoryGirl.generate :metasploit_cache_module_rank
      }

      context 'with seeded' do
        it 'does not create a new Metasploit::Cache::Module::Rank' do
          expect {
            metasploit_cache_module_rank
          }.not_to change(Metasploit::Cache::Module::Rank, :count)
        end

        it { is_expected.to be_a(Metasploit::Cache::Module::Rank) }
        it { is_expected.to be_persisted }
      end

      context 'without seeded' do
        before(:each) do
          Metasploit::Cache::Module::Rank.delete_all
        end

        it 'raises ArgumentError with the name of the unseeded rank' do
          expect {
            metasploit_cache_module_rank
          }.to raise_error(ArgumentError) do |error|
            expect(error.to_s).to match(/Metasploit::Cache::Module::Rank with name \(\S+\) has not been seeded/)
          end
        end
      end
    end
  end

  context 'mass assignment security' do
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:number) }
  end

  context 'search' do
    let(:base_class) {
      Metasploit::Cache::Module::Rank
    }

    context 'attributes' do
      it_should_behave_like 'search_attribute', :name, :type => :string
      it_should_behave_like 'search_attribute', :number, :type => :integer
    end
  end

  context 'validations' do
    it { should validate_uniqueness_of(:name) }

    context 'number' do
      it { should validate_numericality_of(:number).only_integer }
      it { should validate_uniqueness_of(:number) }
    end

    context 'without seeds' do
      before(:each) do
        described_class.delete_all
      end

      context 'name' do
        context 'format' do
          it 'should not allow #name starting with a lowercase letter' do
            expect(module_rank).not_to allow_value('good').for(:name)
          end

          it 'should allow #name starting with a capital letter' do
            expect(module_rank).to allow_value('Good').for(:name)
          end

          it 'should not allow #name with a space' do
            expect(module_rank).not_to allow_value('Super Effective').for(:name)
          end
        end

        it { should validate_inclusion_of(:name).in_array(described_class::NUMBER_BY_NAME.keys) }
      end

      it { should validate_inclusion_of(:number).in_array(described_class::NUMBER_BY_NAME.values) }
    end
  end

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