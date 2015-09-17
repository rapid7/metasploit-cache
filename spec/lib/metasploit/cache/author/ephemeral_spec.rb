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
        it 'raises ActiveRecord::Invalid due to name collision' do
          expect {
            by_name[existing_not_in_name_set.name]
          }.to raise_error ActiveRecord::RecordInvalid
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
          it 'raises ActiveRecord::RecordInvalid due to name collision' do
            expect {
              by_name[existing_not_in_name_set.name]
            }.to raise_error ActiveRecord::RecordInvalid
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

  context 'create_by_name_proc' do
    subject(:create_by_name_proc) {
      described_class.create_by_name_proc.call(hash, name)
    }

    let(:name) {
      FactoryGirl.generate :metasploit_cache_author_name
    }

    let(:hash) {
      {}
    }

    it 'returns newly created Metasploit::Cache::Author' do
      expect(create_by_name_proc).to be_a Metasploit::Cache::Author
      expect(create_by_name_proc).to be_persisted
    end

    it 'set Metasploit::CacheAuthor#name' do
      expect(create_by_name_proc.name).to eq(name)
    end

    it 'caches newly created Metasploit::Cache::Author in hash' do
      returned = create_by_name_proc

      expect(hash[name]).to eq(returned)
    end
  end

  context 'existing_by_name' do
    subject(:existing_by_name) {
      described_class.existing_by_name(name_set: name_set)
    }

    #
    # let!s
    #

    let!(:existing_not_in_name_set) {
      FactoryGirl.create(:metasploit_cache_author)
    }

    context 'with :empty existing_name_set' do
      let(:name_set) {
        Set.new
      }

      context 'with existing Metasploit::Cache::Author#name' do
        it "still returns nil because #name wasn't in :name_set" do
          expect(existing_by_name[existing_not_in_name_set.name]).to be_nil
        end
      end

      context 'without existing Metasploit::Cache::Author#name' do
        let(:name) {
          FactoryGirl.generate :metasploit_cache_author_name
        }

        it 'returns nil' do
          expect(existing_by_name[name]).to be_nil
        end
      end
    end

    context 'with present :name_set' do
      #
      # let
      #

      let(:name_set) {
        Set.new [existing_in_name_set.name]
      }

      #
      # let!s
      #

      let!(:existing_in_name_set) {
        FactoryGirl.create(:metasploit_cache_author)
      }

      context 'with existing Metasploit::Cache::Author#name' do
        context 'in :name_set' do
          it 'returns existing Metasploit::Cache::Author' do
            expect(existing_by_name[existing_in_name_set.name]).to eq(existing_in_name_set)
          end
        end

        context 'not in :name_set' do
          it "still returns nil because #name wasn't in :name_set" do
            expect(existing_by_name[existing_not_in_name_set.name]).to be_nil
          end
        end
      end

      context 'without existing Metasploit::Cache::Author#name' do
        let(:name) {
          FactoryGirl.generate :metasploit_cache_author_name
        }

        it 'returns nil' do
          expect(existing_by_name[name]).to be_nil
        end
      end
    end
  end
end