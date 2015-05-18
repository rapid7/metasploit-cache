RSpec.describe Metasploit::Cache::Licensable::License do
  context "database" do
    context "columns" do
      it { is_expected.to have_db_column(:license_id).of_type(:integer).with_options(null:false) }
      it { is_expected.to have_db_column(:licensable_id).of_type(:integer).with_options(null:false) }
      it { is_expected.to have_db_column(:licensable_type).of_type(:string).with_options(null:false) }
    end
  end

  context "associations" do
    it { is_expected.to belong_to(:licensable)}
    it { is_expected.to belong_to(:license)}
  end

  context "validations" do
    it { is_expected.to validate_presence_of :license }
    # it { is_expected.to validate_uniqueness_of :licensable_id }
    it { is_expected.to validate_presence_of :licensable }
  end

  context "factories" do
    subject(:metasploit_cache_licensable_license){ FactoryGirl.build :metasploit_cache_auxiliary_instance_license }

    it { is_expected.to be_valid }
  end
end
