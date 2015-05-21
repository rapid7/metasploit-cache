RSpec.describe Metasploit::Cache::Licensable::License do
  context "database" do
    context "columns" do
      it { is_expected.to have_db_column(:license_id).of_type(:integer).with_options(null:false) }
      it { is_expected.to have_db_column(:licensable_id).of_type(:integer).with_options(null:false) }
      it { is_expected.to have_db_column(:licensable_type).of_type(:string).with_options(null:false) }
    end
  end

  context "associations" do
    it { is_expected.to belong_to(:licensable) }
    it { is_expected.to belong_to(:license).class_name('Metasploit::Cache::License').inverse_of(:licensable_licenses) }
  end

  context "validations" do
    it { is_expected.to validate_presence_of :license }
    it { is_expected.to validate_presence_of :licensable }

    context 'with existing record' do
      let!(:existing_licensable_license) {
        FactoryGirl.create(:metasploit_cache_auxiliary_license)
      }

      it { is_expected.to validate_uniqueness_of(:license_id).scoped_to(:licensable_type, :licensable_id) }
    end
  end

  context "factories" do
    subject(:metasploit_cache_licensable_license){ FactoryGirl.build :metasploit_cache_auxiliary_license }

    it { is_expected.to be_valid }
  end
end
