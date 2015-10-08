RSpec.describe Metasploit::Cache::Referencable::Reference, type: :model do
  context "database" do
    context "columns" do
      it { is_expected.to have_db_column(:reference_id).of_type(:integer).with_options(null:false) }
      it { is_expected.to have_db_column(:referencable_id).of_type(:integer).with_options(null:false) }
      it { is_expected.to have_db_column(:referencable_type).of_type(:string).with_options(null:false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index(:reference_id).unique(false) }
      it { is_expected.to have_db_index([:referencable_type, :referencable_id]).unique(false) }
      it { is_expected.to have_db_index([:referencable_type, :referencable_id, :reference_id]).unique(true) }
    end
  end

  context "associations" do
    it { is_expected.to belong_to(:referencable) }
    it { is_expected.to belong_to(:reference).class_name('Metasploit::Cache::Reference').inverse_of(:referencable_references).validate(true) }
  end

  context "validations" do
    it { is_expected.to validate_presence_of :reference }
    it { is_expected.to validate_presence_of :referencable }

    context 'with existing record' do
      let!(:existing_referencable_reference) {
        FactoryGirl.create(:metasploit_cache_auxiliary_reference)
      }

      it { is_expected.to validate_uniqueness_of(:reference_id).scoped_to(:referencable_type, :referencable_id) }
    end
  end

  context "factories" do
    subject(:metasploit_cache_referencable_reference){ FactoryGirl.build :metasploit_cache_auxiliary_reference }

    it { is_expected.to be_valid }
  end
end