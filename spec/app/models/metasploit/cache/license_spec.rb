RSpec.describe Metasploit::Cache::License do
  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:abbreviation).of_type(:string).with_options(null: false, unique: true) }
      it { is_expected.to have_db_column(:summary).of_type(:text).with_options(null: false, unique: true) }
      it { is_expected.to have_db_column(:url).of_type(:string).with_options(null: false, unique: true) }
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
    end
  end

  context "validations" do
    context "presence" do
      it { is_expected.to validate_presence_of :abbreviation }
      it { is_expected.to validate_presence_of :summary }
      it { is_expected.to validate_presence_of :url }
    end

    context "uniqueness" do
      subject(:metasploit_cache_license) { FactoryGirl.build(:metasploit_cache_license) }

      it { is_expected.to validate_uniqueness_of :abbreviation }
      it { is_expected.to validate_uniqueness_of :summary }
      it { is_expected.to validate_uniqueness_of :url }
    end
  end

end