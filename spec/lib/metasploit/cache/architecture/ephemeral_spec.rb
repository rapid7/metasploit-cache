RSpec.describe Metasploit::Cache::Architecture::Ephemeral do
  context 'by_abbreviation' do
    subject(:by_abbreviation) {
      described_class.by_abbreviation(existing_abbreviation_set: existing_abbreviation_set)
    }

    #
    # let!s
    #

    let!(:existing_not_in_existing_abbreviation_set) {
      FactoryGirl.generate :metasploit_cache_architecture
    }

    context 'with :empty existing_abbreviation_set' do
      let(:existing_abbreviation_set) {
        Set.new
      }

      context 'with existing Metasploit::Cache::Architecture#abbreviation' do
        it "still returns nil because #abbreviation wasn't in :existing_abbreviation_set" do
          expect(by_abbreviation[existing_not_in_existing_abbreviation_set]).to be_nil
        end
      end

      context 'without existing Metasploit::Cache::Architecture#abbreviation' do
        let(:abbreviation) {
          'asdf'
        }

        it 'returns nil' do
          expect(by_abbreviation[abbreviation]).to be_nil
        end
      end
    end

    context 'with present :existing_abbreviation_set' do
      #
      # let
      #

      let(:existing_abbreviation_set) {
        Set.new [existing_in_existing_abbreviation_set.abbreviation]
      }

      #
      # let!s
      #

      let!(:existing_in_existing_abbreviation_set) {
        FactoryGirl.generate :metasploit_cache_architecture
      }

      context 'with existing Metasploit::Cache::Architecture#abbreviation' do
        context 'in :existing_abbreviation_set' do
          it 'returns existing Metasploit::Cache::Architecture' do
            expect(by_abbreviation[existing_in_existing_abbreviation_set.abbreviation]).to eq(existing_in_existing_abbreviation_set)
          end
        end

        context 'not in :existing_abbreviation_set' do
          it "still returns nil because #abbreviation wasn't in :existing_abbreviation_set" do
            expect(by_abbreviation[existing_not_in_existing_abbreviation_set.abbreviation]).to be_nil
          end
        end
      end

      context 'without existing Metasploit::Cache::Architecture#abbreviation' do
        let(:abbreviation) {
          'asdf'
        }

        it 'returns nil' do
          expect(by_abbreviation[abbreviation]).to be_nil
        end
      end
    end
  end
end