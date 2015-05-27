RSpec.describe Metasploit::Cache::Contribution do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { is_expected.to belong_to(:author).class_name('Metasploit::Cache::Author').inverse_of(:contributions) }
    it { is_expected.to belong_to(:contributable) }
    it { is_expected.to belong_to(:email_address).class_name('Metasploit::Cache::EmailAddress').inverse_of(:contributions) }
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:author_id).of_type(:integer).with_options(null: false) }
      it { is_expected.to have_db_column(:contributable_id).of_type(:integer).with_options(null: false) }
      it { is_expected.to have_db_column(:contributable_type).of_type(:string).with_options(null: false) }
      it { is_expected.to have_db_column(:email_address_id).of_type(:integer).with_options(null: true) }
    end

    context 'indices' do
      it { is_expected.to have_db_index(:author_id).unique(false) }
      it { is_expected.to have_db_index([:contributable_type, :contributable_id]).unique(false) }
      it { is_expected.to have_db_index([:contributable_type, :contributable_id, :author_id]).unique(true) }
      it { is_expected.to have_db_index([:contributable_type, :contributable_id, :email_address_id]).unique(true) }
      it { is_expected.to have_db_index(:email_address_id).unique(false) }
    end
  end
  
  context 'factories' do
    context 'metasploit_cache_auxiliary_contribution' do
      subject(:metasploit_cache_auxiliary_contribution) {
        FactoryGirl.build(:metasploit_cache_auxiliary_contribution)
      }
      
      it { is_expected.to be_valid }
      
      context '#contributable' do
        subject(:contributable) {
          metasploit_cache_auxiliary_contribution.contributable
        }
        
        it { is_expected.to be_a Metasploit::Cache::Auxiliary::Instance }
      end
    end
    
    context 'metasploit_cache_encoder_contribution' do
      subject(:metasploit_cache_encoder_contribution) {
        FactoryGirl.build(:metasploit_cache_encoder_contribution)
      }
      
      it { is_expected.to be_valid }
      
      context '#contributable' do
        subject(:contributable) {
          metasploit_cache_encoder_contribution.contributable
        }
        
        it { is_expected.to be_a Metasploit::Cache::Encoder::Instance }
      end
    end   
    
    context 'metasploit_cache_exploit_contribution' do
      subject(:metasploit_cache_exploit_contribution) {
        FactoryGirl.build(:metasploit_cache_exploit_contribution)
      }
      
      it { is_expected.to be_valid }
      
      context '#contributable' do
        subject(:contributable) {
          metasploit_cache_exploit_contribution.contributable
        }
        
        it { is_expected.to be_a Metasploit::Cache::Exploit::Instance }
      end
    end
    
    context 'metasploit_cache_nop_contribution' do
      subject(:metasploit_cache_nop_contribution) {
        FactoryGirl.build(:metasploit_cache_nop_contribution)
      }
      
      it { is_expected.to be_valid }
      
      context '#contributable' do
        subject(:contributable) {
          metasploit_cache_nop_contribution.contributable
        }
        
        it { is_expected.to be_a Metasploit::Cache::Nop::Instance }
      end
    end

    context 'metasploit_cache_payload_single_contribution' do
      subject(:metasploit_cache_payload_single_contribution) {
        FactoryGirl.build(:metasploit_cache_payload_single_contribution)
      }

      it { is_expected.to be_valid }

      context '#contributable' do
        subject(:contributable) {
          metasploit_cache_payload_single_contribution.contributable
        }

        it { is_expected.to be_a Metasploit::Cache::Payload::Single::Instance }
      end
    end

    context 'metasploit_cache_payload_stage_contribution' do
      subject(:metasploit_cache_payload_stage_contribution) {
        FactoryGirl.build(:metasploit_cache_payload_stage_contribution)
      }

      it { is_expected.to be_valid }

      context '#contributable' do
        subject(:contributable) {
          metasploit_cache_payload_stage_contribution.contributable
        }

        it { is_expected.to be_a Metasploit::Cache::Payload::Stage::Instance }
      end
    end

    context 'metasploit_cache_payload_stager_contribution' do
      subject(:metasploit_cache_payload_stager_contribution) {
        FactoryGirl.build(:metasploit_cache_payload_stager_contribution)
      }

      it { is_expected.to be_valid }

      context '#contributable' do
        subject(:contributable) {
          metasploit_cache_payload_stager_contribution.contributable
        }

        it { is_expected.to be_a Metasploit::Cache::Payload::Stager::Instance }
      end
    end

    context 'metasploit_cache_post_contribution' do
      subject(:metasploit_cache_post_contribution) {
        FactoryGirl.build(:metasploit_cache_post_contribution)
      }

      it { is_expected.to be_valid }

      context '#contributable' do
        subject(:contributable) {
          metasploit_cache_post_contribution.contributable
        }

        it { is_expected.to be_a Metasploit::Cache::Post::Instance }
      end
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :author }
    it { is_expected.to validate_presence_of :contributable }

    context 'with existing record' do
      let!(:existing_contribution) {
        FactoryGirl.create(:metasploit_cache_auxiliary_contribution, :metasploit_cache_contribution_email_address)
      }

      it { is_expected.to validate_uniqueness_of(:author).scoped_to(:contributable) }
      it { is_expected.to validate_uniqueness_of(:email_address).scoped_to(:contributable).allow_blank }
    end
  end
end