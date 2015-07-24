RSpec.describe Metasploit::Cache::Licensable::License do
  context "database" do
    context "columns" do
      it { is_expected.to have_db_column(:license_id).of_type(:integer).with_options(null:false) }
      it { is_expected.to have_db_column(:licensable_id).of_type(:integer).with_options(null:false) }
      it { is_expected.to have_db_column(:licensable_type).of_type(:string).with_options(null:false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index(:license_id).unique(false) }
      it { is_expected.to have_db_index([:licensable_type, :licensable_id]).unique(false) }
      it { is_expected.to have_db_index([:licensable_type, :licensable_id, :license_id]).unique(true) }
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
    context 'metasploit_cache_licensable_license' do
      subject(:metasploit_cache_licensable_license) {
        FactoryGirl.build(:metasploit_cache_licensable_license)
      }
      
      it { is_expected.not_to be_valid }
      
      it 'has nil #licensable' do
        expect(metasploit_cache_licensable_license.licensable).to be_nil
      end
    end
    
    context 'metasploit_cache_auxiliary_license' do
      subject(:metasploit_cache_auxiliary_license) {
        FactoryGirl.build(:metasploit_cache_auxiliary_license)
      }
      
      it { is_expected.to be_valid }
    end
     
    context 'metasploit_cache_encoder_license' do
      subject(:metasploit_cache_encoder_license) {
        FactoryGirl.build(:metasploit_cache_encoder_license)
      }
      
      it { is_expected.to be_valid }
    end   
     
    context 'metasploit_cache_exploit_license' do
      subject(:metasploit_cache_exploit_license) {
        FactoryGirl.build(:metasploit_cache_exploit_license)
      }
      
      it { is_expected.to be_valid }
    end   
     
    context 'metasploit_cache_nop_license' do
      subject(:metasploit_cache_nop_license) {
        FactoryGirl.build(:metasploit_cache_nop_license)
      }
      
      it { is_expected.to be_valid }
    end   
     
    context 'metasploit_cache_payload_single_license' do
      subject(:metasploit_cache_payload_single_license) {
        FactoryGirl.build(:metasploit_cache_payload_single_license)
      }
      
      it { is_expected.to be_valid }
    end   
     
    context 'metasploit_cache_payload_stage_license' do
      subject(:metasploit_cache_payload_stage_license) {
        FactoryGirl.build(:metasploit_cache_payload_stage_license)
      }
      
      it { is_expected.to be_valid }
    end   
    
    context 'metasploit_cache_payload_stager_license' do
      subject(:metasploit_cache_payload_stager_license) {
        FactoryGirl.build(:metasploit_cache_payload_stager_license)
      }
      
      it { is_expected.to be_valid }
    end    
        
    context 'metasploit_cache_post_license' do
      subject(:metasploit_cache_post_license) {
        FactoryGirl.build(:metasploit_cache_post_license)
      }
      
      it { is_expected.to be_valid }
    end
  end
end
