RSpec.describe Metasploit::Cache::Ephemeral::AttributeSet do
  context 'added' do
    subject(:added) {
      described_class.added(
          destination: destination,
          source: source
      )
    }

    let(:destination) {
      Set.new [:common, :destination]
    }

    let(:source) {
      Set.new [:added, :common]
    }

    it 'substracts :destination from :source' do
      expect(added).to eq(Set.new [:added])
    end
  end

  context 'existing_by_attribute_value' do
    subject(:existing_by_attribute_value) {
      described_class.existing_by_attribute_value(
          attribute: :abbreviation,
          scope: Metasploit::Cache::Architecture,
          value_set: value_set
      )
    }

    #
    # let!s
    #

    let!(:existing_not_in_value_set) {
      FactoryGirl.generate :metasploit_cache_architecture
    }

    context 'with empty value_set' do
      let(:value_set) {
        Set.new
      }

      context 'with existing attribute value' do
        it "still returns nil because value wasn't in :value_set" do
          expect(existing_by_attribute_value[existing_not_in_value_set.abbreviation]).to be_nil
        end
      end

      context 'without existing attribute value' do
        let(:value) {
          'asdf'
        }

        it 'returns nil' do
          expect(existing_by_attribute_value[value]).to be_nil
        end
      end
    end

    context 'with present value_set' do
      #
      # let
      #

      let(:value_set) {
        Set.new [existing_in_value_set.abbreviation]
      }

      #
      # let!s
      #

      let!(:existing_in_value_set) {
        FactoryGirl.generate :metasploit_cache_architecture
      }

      context 'with existing attribute value' do
        context 'in value_set' do
          it 'returns existing record' do
            expect(existing_by_attribute_value[existing_in_value_set.abbreviation]).to eq(existing_in_value_set)
          end
        end

        context 'not in value_set' do
          it "still returns nil because attribute value wasn't in value_set" do
            expect(existing_by_attribute_value[existing_not_in_value_set.abbreviation]).to be_nil
          end
        end
      end

      context 'without existing attribute value' do
        let(:value) {
          'asdf'
        }

        it 'returns nil' do
          expect(existing_by_attribute_value[value]).to be_nil
        end
      end
    end
  end

  context 'removed' do
    subject(:removed) {
      described_class.removed(
          destination: destination,
          source: source
      )
    }

    let(:destination) {
      Set.new [:common, :removed]
    }

    let(:source) {
      Set.new [:common]
    }

    it 'substracts :source from :destination' do
      expect(removed).to eq(Set.new [:removed])
    end
  end
end