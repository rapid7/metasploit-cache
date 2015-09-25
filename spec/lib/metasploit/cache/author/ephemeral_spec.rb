RSpec.describe Metasploit::Cache::Author::Ephemeral do
  context 'by_name' do
    subject(:by_name) {
      described_class.by_name(existing_name_set: existing_name_set)
    }

    #
    # let!s
    #

    let!(:existing_not_in_name_set) {
      FactoryGirl.create(:metasploit_cache_author)
    }

    context 'with :empty existing_name_set' do
      let(:existing_name_set) {
        Set.new
      }

      context 'with existing Metasploit::Cache::Author#name' do
        it 'returns existing Metasploit::Cache::Author' do
          expect(by_name[existing_not_in_name_set.name]).to eq(existing_not_in_name_set)
        end
      end

      context 'without existing Metasploit::Cache::Author#name' do
        let(:name) {
          FactoryGirl.generate :metasploit_cache_author_name
        }

        it 'returns a newly created Metasploit::Cache::Author' do
          expect(by_name[name]).to be_persisted
        end
      end
    end

    context 'with present :existing_name_set' do
      #
      # let
      #

      let(:existing_name_set) {
        Set.new [existing_in_name_set.name]
      }

      #
      # let!s
      #

      let!(:existing_in_name_set) {
        FactoryGirl.create(:metasploit_cache_author)
      }

      context 'with existing Metasploit::Cache::Author#name' do
        context 'in :existing_name_set' do
          it 'returns existing Metasploit::Cache::Author' do
            expect(by_name[existing_in_name_set.name]).to eq(existing_in_name_set)
          end
        end

        context 'not in :existing_name_set' do
          it 'returns existing Metasploit::Cache::Author' do
            expect(by_name[existing_not_in_name_set.name]).to eq(existing_not_in_name_set)
          end
        end
      end

      context 'without existing Metasploit::Cache::Author#name' do
        let(:name) {
          FactoryGirl.generate :metasploit_cache_author_name
        }

        it 'returns a newly created Metasploit::Cache::Author' do
          expect(by_name[name]).to be_persisted
        end
      end
    end
  end
end