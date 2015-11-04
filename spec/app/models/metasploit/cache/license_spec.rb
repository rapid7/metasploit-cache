RSpec.describe Metasploit::Cache::License, type: :model do
  context 'associations' do
    it { is_expected.to have_many(:licensable_licenses).class_name('Metasploit::Cache::Licensable::License').dependent(:destroy).inverse_of(:license) }
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:abbreviation).of_type(:string).with_options(null: false) }
      it { is_expected.to have_db_column(:summary).of_type(:text).with_options(null: true) }
      it { is_expected.to have_db_column(:url).of_type(:string).with_options(null: true) }
    end

    context "indices" do
      it {is_expected.to have_db_index(:abbreviation).unique(true)}
      it {is_expected.to have_db_index(:summary).unique(true)}
      it {is_expected.to have_db_index(:url).unique(true)}
    end
  end

  context 'factories' do
    context :metasploit_cache_license do
      subject(:metasploit_cache_license) { FactoryGirl.build(:metasploit_cache_license) }

      it { is_expected.to be_valid }

      it 'does not have #summary' do
        expect(metasploit_cache_license.summary).to be_nil
      end

      it 'does not have #url' do
        expect(metasploit_cache_license.url).to be_nil
      end
    end

    context 'full_metasploit_cache_license' do
      subject(:full_metasploit_cache_license) {
        FactoryGirl.build(:full_metasploit_cache_license)
      }

      it { is_expected.to be_valid }

      it 'has #summary' do
        expect(full_metasploit_cache_license.summary).to be_present
      end

      it 'has #url' do
        expect(full_metasploit_cache_license.url).to be_present
      end
    end
  end

  context "validations" do
    context "presence" do
      it { is_expected.to validate_presence_of :abbreviation }
    end

    context "uniqueness" do
      subject(:metasploit_cache_license) { FactoryGirl.build(:metasploit_cache_license) }

      it { is_expected.to validate_uniqueness_of :abbreviation }
      it { is_expected.to validate_uniqueness_of(:summary).allow_nil }
      it { is_expected.to validate_uniqueness_of(:url).allow_nil }
    end
  end

end