RSpec.describe Metasploit::Cache::Payload::Staged::Class, type: :model do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'association' do
    it { is_expected.to belong_to(:payload_stage_instance).class_name('Metasploit::Cache::Payload::Stage::Instance').inverse_of(:payload_staged_classes) }
    it { is_expected.to belong_to(:payload_stager_instance).class_name('Metasploit::Cache::Payload::Stager::Instance').inverse_of(:payload_staged_classes) }
  end

  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:payload_stage_instance_id).of_type(:integer).with_options(null: false) }
      it { is_expected.to have_db_column(:payload_stager_instance_id).of_type(:integer).with_options(null: false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index(:payload_stage_instance_id).unique(false) }
      it { is_expected.to have_db_index(:payload_stager_instance_id).unique(false) }
      it { is_expected.to have_db_index([:payload_stager_instance_id, :payload_stage_instance_id]).unique(true) }
    end
  end

  context 'factories' do
    context 'metasploit_cache_payload_staged_class' do
      subject(:metasploit_cache_payload_staged_class) {
        FactoryGirl.build(:metasploit_cache_payload_staged_class)
      }

      it { is_expected.to be_valid }
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :payload_stage_instance }
    it { is_expected.to validate_presence_of :payload_stager_instance }

    context 'validates compatible architectures' do
      subject(:base_errors) {
        payload_staged_class.errors[:base]
      }

      let(:error) {
        I18n.translate!('activerecord.errors.models.metasploit/cache/payload/staged/class.incompatible_architectures')
      }

      let(:payload_staged_class) {
        FactoryGirl.build(
            :metasploit_cache_payload_staged_class,
            payload_stage_instance: payload_stage_instance,
            payload_stager_instance: payload_stager_instance
        )
      }

      let(:payload_stage_instance) {
        FactoryGirl.build(
            :metasploit_cache_payload_stage_instance,
            architecturable_architecture_count: 0
        ).tap { |payload_stage_instance|
          payload_stage_instance.architecturable_architectures << Metasploit::Cache::Architecturable::Architecture.new(
              architecturable: payload_stage_instance,
              architecture: first_stage_architecture
          )

          payload_stage_instance.architecturable_architectures << Metasploit::Cache::Architecturable::Architecture.new(
              architecturable: payload_stage_instance,
              architecture: second_stage_architecture
          )
        }
      }

      let(:payload_stager_instance) {
        FactoryGirl.build(
            :metasploit_cache_payload_stager_instance,
            architecturable_architecture_count: 0
        ).tap { |payload_stager_instance|
          payload_stager_instance.architecturable_architectures << Metasploit::Cache::Architecturable::Architecture.new(
              architecturable: payload_stager_instance,
              architecture: first_stager_architecture
          )
          payload_stager_instance.architecturable_architectures << Metasploit::Cache::Architecturable::Architecture.new(
              architecturable: payload_stager_instance,
              architecture: second_stager_architecture
          )
        }
      }

      context 'with intersecting architectures' do
        #
        # lets
        #

        let(:first_stage_architecture) {
          Metasploit::Cache::Architecture.where(abbreviation: 'armbe').first
        }

        let(:first_stager_architecture) {
          first_stage_architecture
        }

        let(:second_stage_architecture) {
          Metasploit::Cache::Architecture.where(abbreviation: 'armle').first
        }

        let(:second_stager_architecture) {
          Metasploit::Cache::Architecture.where(abbreviation: 'cbea').first
        }

        #
        # Callbacks
        #

        before(:each) do
          payload_stage_instance.save!
          payload_stager_instance.save!

          payload_staged_class.valid?
        end

        it { is_expected.not_to include error }
      end

      context 'without intersecting architectures' do
        #
        # lets
        #

        let(:first_stage_architecture) {
          Metasploit::Cache::Architecture.where(abbreviation: 'armbe').first
        }

        let(:first_stager_architecture) {
          Metasploit::Cache::Architecture.where(abbreviation: 'cbea').first
        }

        let(:second_stage_architecture) {
          Metasploit::Cache::Architecture.where(abbreviation: 'armle').first
        }

        let(:second_stager_architecture) {
          Metasploit::Cache::Architecture.where(abbreviation: 'cbea64').first
        }

        #
        # Callbacks
        #

        before(:each) do
          payload_stage_instance.save!
          payload_stager_instance.save!

          payload_staged_class.valid?
        end

        it { is_expected.to include error }
      end
    end

    context 'validates compatible platforms' do
      subject(:base_errors) {
        payload_staged_class.errors[:base]
      }

      let(:error) {
        I18n.translate!('activerecord.errors.models.metasploit/cache/payload/staged/class.incompatible_platforms')
      }

      let(:payload_staged_class) {
        FactoryGirl.build(
            :metasploit_cache_payload_staged_class,
            payload_stage_instance: payload_stage_instance,
            payload_stager_instance: payload_stager_instance
        )
      }

      let(:payload_stage_instance) {
        FactoryGirl.build(
            :metasploit_cache_payload_stage_instance,
            platformable_platform_count: 0
        ).tap { |payload_stage_instance|
          payload_stage_instance.platformable_platforms << Metasploit::Cache::Platformable::Platform.new(
              platformable: payload_stage_instance,
              platform: stage_platform
          )
        }
      }

      let(:payload_stager_instance) {
        FactoryGirl.build(
            :metasploit_cache_payload_stager_instance,
            platformable_platform_count: 0
        ).tap { |payload_stager_instance|
          payload_stager_instance.platformable_platforms << Metasploit::Cache::Platformable::Platform.new(
              platformable: payload_stager_instance,
              platform: stager_platform
          )
        }
      }

      context 'with same platform' do
        #
        # lets
        #

        let(:stage_platform) {
          Metasploit::Cache::Platform.where(fully_qualified_name: 'AIX').first
        }

        let(:stager_platform) {
          stage_platform
        }

        #
        # Callbacks
        #

        before(:each) do
          payload_stage_instance.save!
          payload_stager_instance.save!

          payload_staged_class.valid?
        end

        it { is_expected.not_to include error }
      end

      context 'with stage platform a child of stager platform' do
        let(:stage_platform) {
          Metasploit::Cache::Platform.where(fully_qualified_name: 'Windows 95').first
        }

        let(:stager_platform) {
          Metasploit::Cache::Platform.where(fully_qualified_name: 'Windows').first
        }

        #
        # Callbacks
        #

        before(:each) do
          payload_stage_instance.save!
          payload_stager_instance.save!

          payload_staged_class.valid?
        end

        it { is_expected.not_to include error }
      end

      context 'with stager platform a child of stage platform' do
        let(:stage_platform) {
          Metasploit::Cache::Platform.where(fully_qualified_name: 'Windows').first
        }

        let(:stager_platform) {
          Metasploit::Cache::Platform.where(fully_qualified_name: 'Windows 95').first
        }

        #
        # Callbacks
        #

        before(:each) do
          payload_stage_instance.save!
          payload_stager_instance.save!

          payload_staged_class.valid?
        end

        it { is_expected.not_to include error }
      end

      context 'without intersecting platforms' do
        let(:stage_platform) {
          Metasploit::Cache::Platform.where(fully_qualified_name: 'Windows 95').first
        }

        let(:stager_platform) {
          Metasploit::Cache::Platform.where(fully_qualified_name: 'Windows 98').first
        }

        #
        # Callbacks
        #

        before(:each) do
          payload_stage_instance.save!
          payload_stager_instance.save!

          payload_staged_class.valid?
        end

        it { is_expected.to include error }
      end
    end

    context 'existing record' do
      let!(:existing_payload_staged_class) {
        FactoryGirl.create(:metasploit_cache_payload_staged_class)
      }

      it { is_expected.to validate_uniqueness_of(:payload_stage_instance_id).scoped_to(:payload_stager_instance_id) }
    end
  end
end