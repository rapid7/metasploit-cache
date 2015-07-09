RSpec.describe Metasploit::Cache::EmailAddress::Ephemeral do
  context 'by_full' do
    subject(:by_full) {
      described_class.by_full(existing_full_set: existing_full_set)
    }

    #
    # let!s
    #

    let!(:existing_not_in_full_set) {
      FactoryGirl.create(:metasploit_cache_email_address)
    }

    context 'with :empty existing_full_set' do
      let(:existing_full_set) {
        Set.new
      }

      context 'with existing Metasploit::Cache::EmailAddress#full' do
        it "still returns a new Metasploit::Cache::EmailAddress because #full wasn't in :existing_full_set" do
          expect(by_full[existing_not_in_full_set.full]).to be_new_record
        end
      end

      context 'without existing Metasploit::Cache::EmailAddress#full' do
        let(:domain) {
          FactoryGirl.generate :metasploit_cache_email_address_domain
        }

        let(:full) {
          "#{local}@#{domain}"
        }

        let(:local) {
          FactoryGirl.generate :metasploit_cache_email_address_local
        }

        it 'returns a new Metasploit::Cache::EmailAddress' do
          expect(by_full[full]).to be_new_record
        end
      end
    end

    context 'with present :existing_full_set' do
      #
      # let
      #

      let(:existing_full_set) {
        Set.new [existing_in_full_set.full]
      }

      #
      # let!s
      #

      let!(:existing_in_full_set) {
        FactoryGirl.create(:metasploit_cache_email_address)
      }

      context 'with existing Metasploit::Cache::EmailAddress#full' do
        context 'in :existing_full_set' do
          it 'returns existing Metasploit::Cache::EmailAddress' do
            expect(by_full[existing_in_full_set.full]).to eq(existing_in_full_set)
          end
        end

        context 'not in :existing_full_set' do
          it "still returns a new Metasploit::Cache::EmailAddress because #full wasn't in :existing_full_set" do
            expect(by_full[existing_not_in_full_set.full]).to be_new_record
          end
        end
      end

      context 'without existing Metasploit::Cache::EmailAddress#full' do
        let(:domain) {
          FactoryGirl.generate :metasploit_cache_email_address_domain
        }

        let(:full) {
          "#{local}@#{domain}"
        }

        let(:local) {
          FactoryGirl.generate :metasploit_cache_email_address_local
        }

        it 'returns a new Metasploit::Cache::EmailAddress' do
          expect(by_full[full]).to be_new_record
        end
      end
    end
  end

  context 'existing_by_full' do
    subject(:existing_by_full) {
      described_class.existing_by_full(full_set: full_set)
    }

    #
    # let!s
    #

    let!(:existing_not_in_full_set) {
      FactoryGirl.create(:metasploit_cache_email_address)
    }

    context 'with :empty existing_full_set' do
      let(:full_set) {
        Set.new
      }

      context 'with existing Metasploit::Cache::EmailAddress#full' do
        it "still returns nil because #full wasn't in :full_set" do
          expect(existing_by_full[existing_not_in_full_set.full]).to be_nil
        end
      end

      context 'without existing Metasploit::Cache::EmailAddress#full' do
        let(:domain) {
          FactoryGirl.generate :metasploit_cache_email_address_domain
        }

        let(:full) {
          "#{local}@#{domain}"
        }

        let(:local) {
          FactoryGirl.generate :metasploit_cache_email_address_local
        }

        it 'returns nil' do
          expect(existing_by_full[full]).to be_nil
        end
      end
    end

    context 'with present :full_set' do
      #
      # let
      #

      let(:full_set) {
        Set.new [existing_in_full_set.full]
      }

      #
      # let!s
      #

      let!(:existing_in_full_set) {
        FactoryGirl.create(:metasploit_cache_email_address)
      }

      context 'with existing Metasploit::Cache::EmailAddress#full' do
        context 'in :full_set' do
          it 'returns existing Metasploit::Cache::EmailAddress' do
            expect(existing_by_full[existing_in_full_set.full]).to eq(existing_in_full_set)
          end
        end

        context 'not in :full_set' do
          it "still returns nil because #full wasn't in :full_set" do
            expect(existing_by_full[existing_not_in_full_set.full]).to be_nil
          end
        end
      end

      context 'without existing Metasploit::Cache::EmailAddress#full' do
        let(:domain) {
          FactoryGirl.generate :metasploit_cache_email_address_domain
        }

        let(:full) {
          "#{local}@#{domain}"
        }

        let(:local) {
          FactoryGirl.generate :metasploit_cache_email_address_local
        }

        it 'returns nil' do
          expect(existing_by_full[full]).to be_nil
        end
      end
    end
  end

  context 'new_by_full_proc' do
    subject(:new_by_full_proc) {
      described_class.new_by_full_proc.call(hash, full)
    }

    let(:domain) {
      FactoryGirl.generate :metasploit_cache_email_address_domain
    }

    let(:full) {
      "#{local}@#{domain}"
    }

    let(:hash) {
      {}
    }

    let(:local) {
      FactoryGirl.generate :metasploit_cache_email_address_local
    }

    it 'returns new Metasploit::Cache::EmailAddress' do
      expect(new_by_full_proc).to be_a Metasploit::Cache::EmailAddress
      expect(new_by_full_proc).to be_new_record
    end

    it 'set Metasploit::CacheEmailAddress#full' do
      expect(new_by_full_proc.full).to eq(full)
    end

    it 'caches new Metasploit::Cache::EmailAddress in hash' do
      returned = new_by_full_proc

      expect(hash[full]).to eq(returned)
    end
  end
end