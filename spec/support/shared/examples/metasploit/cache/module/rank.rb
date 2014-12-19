Metasploit::Cache::Spec.shared_examples_for 'Module::Rank' do
  subject(:module_rank) do
    # need non-factory subject since ranks are only seeded and so a sequence.
    # The sequence elements can't be used as they are frozen.
    module_rank_class.new
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

  context 'mass assignment security' do
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:number) }
  end

  context 'search' do
    context 'attributes' do
      it_should_behave_like 'search_attribute', :name, :type => :string
      it_should_behave_like 'search_attribute', :number, :type => :integer
    end
  end

  context 'validations' do
    context 'name' do
      it { should ensure_inclusion_of(:name).in_array(described_class::NUMBER_BY_NAME.keys) }

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
    end

    context 'number' do
      it { should ensure_inclusion_of(:number).in_array(described_class::NUMBER_BY_NAME.values) }
      it { should validate_numericality_of(:number).only_integer }
    end
  end
end