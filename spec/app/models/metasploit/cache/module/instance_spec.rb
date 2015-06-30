RSpec.describe Metasploit::Cache::Module::Instance do
  #
  # Shared contexts
  #

  shared_context 'platforms' do
    #
    # lets
    #

    let(:platform) do
      Metasploit::Cache::Platform.where(fully_qualified_name: platform_fully_qualified_name).first
    end

    let(:platform_fully_qualified_name) do
      'Windows XP'
    end

    let(:other_module_class) do
      FactoryGirl.create(
          :metasploit_cache_module_class,
          module_type: other_module_type
      )
    end

    let(:other_module_type) do
      'payload'
    end

    let(:other_platform) do
      Metasploit::Cache::Platform.where(fully_qualified_name: other_platform_fully_qualified_name).first
    end

    #
    # let!s
    #

    let!(:other_module_instance) do
      FactoryGirl.build(
          :metasploit_cache_module_instance,
          module_class: other_module_class,
          module_platforms_length: 0
      ).tap { |module_instance|
        module_instance.module_platforms.build(
            platform: other_platform
        )
        module_instance.save!
      }
    end
  end

  #
  # Shared Examples
  #

  shared_examples_for 'intersecting platforms' do
    context 'with same platform' do
      let(:other_platform) do
        platform
      end

      it 'includes the Metasploit::Cache::Module::Instance' do
        expect(subject).to include(other_module_instance)
      end
    end

    context 'with ancestor platform' do
      let(:other_platform_fully_qualified_name) do
        'Windows'
      end

      it 'includes the Metasploit::Cache::Module::Instance' do
        expect(subject).to include(other_module_instance)
      end
    end

    context 'with descendant platform' do
      let(:other_platform_fully_qualified_name) do
        'Windows XP SP1'
      end

      it 'includes the Metasploit::Cache::Module::Instance' do
        expect(subject).to include(other_module_instance)
      end
    end

    context 'with cousin platform' do
      let(:other_platform_fully_qualified_name) do
        'Windows XP SP1'
      end

      let(:platform_fully_qualified_name) do
        'Windows 2000 SP1'
      end

      it 'does not include Metasploit::Cache::Module::Instance' do
        expect(subject).not_to include(other_module_instance)
      end
    end

    context 'with unrelated platform' do
      let(:other_platform_fully_qualified_name) do
        'UNIX'
      end

      it 'does not include Metasploit::Cache::Module::Instance' do
        expect(subject).not_to include(other_module_instance)
      end
    end
  end

  subject(:module_instance) do
    FactoryGirl.build(:metasploit_cache_module_instance)
  end

  context 'CONSTANTS' do
    context 'DYNAMIC_LENGTH_VALIDATION_OPTIONS_BY_MODULE_TYPE_BY_ATTRIBUTE' do
      subject(:dynamic_length_validation_options) do
        dynamic_length_validation_options_by_module_type[module_type]
      end

      let(:dynamic_length_validation_options_by_module_type) do
        dynamic_length_validation_options_by_module_type_by_attribute[attribute]
      end

      let(:dynamic_length_validation_options_by_module_type_by_attribute) do
        described_class::DYNAMIC_LENGTH_VALIDATION_OPTIONS_BY_MODULE_TYPE_BY_ATTRIBUTE
      end

      context "[:actions]" do
        let(:attribute) do
          :actions
        end

        context "['auxiliary']" do
          let(:module_type) do
            'auxiliary'
          end

          context "[:minimum]" do
            subject(:minimum) {
              dynamic_length_validation_options[:minimum]
            }

            it { is_expected.to eq(0) }
          end
        end

        context "['encoder']" do
          let(:module_type) do
            'encoder'
          end

          context "[:is]" do
            subject(:is) {
              dynamic_length_validation_options[:is]
            }

            it { is_expected.to eq(0) }
          end
        end

        context "['exploit']" do
          let(:module_type) do
            'exploit'
          end

          context "[:is]" do
            subject(:is) {
              dynamic_length_validation_options[:is]
            }

            it { is_expected.to eq(0) }
          end
        end

        context "['nop']" do
          let(:module_type) do
            'nop'
          end

          context "[:is]" do
            subject(:is) {
              dynamic_length_validation_options[:is]
            }

            it { is_expected.to eq(0) }
          end
        end

        context "['payload']" do
          let(:module_type) do
            'payload'
          end

          context "[:is]" do
            subject(:is) {
              dynamic_length_validation_options[:is]
            }

            it { is_expected.to eq(0) }
          end
        end

        context "['post']" do
          let(:module_type) do
            'post'
          end

          context "[:minimum]" do
            subject(:minimum) {
              dynamic_length_validation_options[:minimum]
            }

            it { is_expected.to eq(0) }
          end
        end
      end

      context '[:module_architectures:]' do
        let(:attribute) do
          :module_architectures
        end

        context "['auxiliary']" do
          let(:module_type) do
            'auxiliary'
          end

          context "[:is]" do
            subject(:is) {
              dynamic_length_validation_options[:is]
            }

            it { is_expected.to eq(0) }
          end
        end

        context "['encoder']" do
          let(:module_type) do
            'encoder'
          end

          context "[:minimum]" do
            subject(:minimum) {
              dynamic_length_validation_options[:minimum]
            }

            it { is_expected.to eq(1) }
          end
        end

        context "['exploit']" do
          let(:module_type) do
            'exploit'
          end

          context "[:minimum]" do
            subject(:minimum) {
              dynamic_length_validation_options[:minimum]
            }

            it { is_expected.to eq(1) }
          end
        end

        context "['nop']" do
          let(:module_type) do
            'nop'
          end

          context "[:minimum]" do
            subject(:minimum) {
              dynamic_length_validation_options[:minimum]
            }

            it { is_expected.to eq(1) }
          end
        end

        context "['payload']" do
          let(:module_type) do
            'payload'
          end

          context "[:minimum]" do
            subject(:minimum) {
              dynamic_length_validation_options[:minimum]
            }

            it { is_expected.to eq(1) }
          end
        end

        context "['post']" do
          let(:module_type) do
            'post'
          end

          context "[:minimum]" do
            subject(:minimum) {
              dynamic_length_validation_options[:minimum]
            }

            it { is_expected.to eq(1) }
          end
        end
      end

      context '[:module_platforms]' do
        let(:attribute) do
          :module_platforms
        end

        context "['auxiliary']" do
          let(:module_type) do
            'auxiliary'
          end

          context "[:is]" do
            subject(:is) {
              dynamic_length_validation_options[:is]
            }

            it { is_expected.to eq(0) }
          end
        end

        context "['encoder']" do
          let(:module_type) do
            'encoder'
          end

          context "[:is]" do
            subject(:is) {
              dynamic_length_validation_options[:is]
            }

            it { is_expected.to eq(0) }
          end
        end

        context "['exploit']" do
          let(:module_type) do
            'exploit'
          end

          context "[:minimum]" do
            subject(:minimum) {
              dynamic_length_validation_options[:minimum]
            }

            it { is_expected.to eq(1) }
          end
        end

        context "['nop']" do
          let(:module_type) do
            'nop'
          end

          context "[:is]" do
            subject(:is) {
              dynamic_length_validation_options[:is]
            }

            it { is_expected.to eq(0) }
          end
        end

        context "['payload']" do
          let(:module_type) do
            'payload'
          end

          context "[:minimum]" do
            subject(:minimum) {
              dynamic_length_validation_options[:minimum]
            }

            it { is_expected.to eq(1) }
          end
        end

        context "['post']" do
          let(:module_type) do
            'post'
          end

          context "[:minimum]" do
            subject(:minimum) {
              dynamic_length_validation_options[:minimum]
            }

            it { is_expected.to eq(1) }
          end
        end
      end

      context '[:module_references]' do
        let(:attribute) do
          :module_references
        end

        context "['auxiliary']" do
          let(:module_type) do
            'auxiliary'
          end

          context "[:minimum]" do
            subject(:minimum) {
              dynamic_length_validation_options[:minimum]
            }

            it { is_expected.to eq(0) }
          end
        end

        context "['encoder']" do
          let(:module_type) do
            'encoder'
          end

          context "[:is]" do
            subject(:is) {
              dynamic_length_validation_options[:is]
            }

            it { is_expected.to eq(0) }
          end
        end

        context "['exploit']" do
          let(:module_type) do
            'exploit'
          end

          context "[:minimum]" do
            subject(:minimum) {
              dynamic_length_validation_options[:minimum]
            }

            it { is_expected.to eq(1) }
          end
        end

        context "['nop']" do
          let(:module_type) do
            'nop'
          end

          context "[:is]" do
            subject(:is) {
              dynamic_length_validation_options[:is]
            }

            it { is_expected.to eq(0) }
          end
        end

        context "['payload']" do
          let(:module_type) do
            'payload'
          end

          context "[:is]" do
            subject(:is) {
              dynamic_length_validation_options[:is]
            }

            it { is_expected.to eq(0) }
          end
        end

        context "['post']" do
          let(:module_type) do
            'post'
          end

          context "[:minimum]" do
            subject(:minimum) {
              dynamic_length_validation_options[:minimum]
            }

            it { is_expected.to eq(0) }
          end
        end
      end

      context '[:targets]' do
        let(:attribute) do
          :targets
        end

        context "['auxiliary']" do
          let(:module_type) do
            'auxiliary'
          end

          context "[:is]" do
            subject(:is) {
              dynamic_length_validation_options[:is]
            }

            it { is_expected.to eq(0) }
          end
        end

        context "['encoder']" do
          let(:module_type) do
            'encoder'
          end

          context "[:is]" do
            subject(:is) {
              dynamic_length_validation_options[:is]
            }

            it { is_expected.to eq(0) }
          end
        end

        context "['exploit']" do
          let(:module_type) do
            'exploit'
          end

          context "[:minimum]" do
            subject(:minimum) {
              dynamic_length_validation_options[:minimum]
            }

            it { is_expected.to eq(1) }
          end
        end

        context "['nop']" do
          let(:module_type) do
            'nop'
          end

          context "[:is]" do
            subject(:is) {
              dynamic_length_validation_options[:is]
            }

            it { is_expected.to eq(0) }
          end
        end

        context "['payload']" do
          let(:module_type) do
            'payload'
          end

          context "[:is]" do
            subject(:is) {
              dynamic_length_validation_options[:is]
            }

            it { is_expected.to eq(0) }
          end
        end

        context "['post']" do
          let(:module_type) do
            'post'
          end

          context "[:is]" do
            subject(:is) {
              dynamic_length_validation_options[:is]
            }

            it { is_expected.to eq(0) }
          end
        end
      end
    end

    context 'MINIMUM_MODULE_AUTHORS_LENGTH' do
      subject(:minimum_module_authors_length) do
        described_class::MINIMUM_MODULE_AUTHORS_LENGTH
      end

      it { should == 1 }
    end

    context 'PRIVILEGES' do
      subject(:privileges) do
        described_class::PRIVILEGES
      end

      it 'should contain both Boolean values' do
        expect(privileges).to include(false)
        expect(privileges).to include(true)
      end
    end
  end

  context 'associations' do
    it { should have_many(:actions).class_name('Metasploit::Cache::Module::Action').dependent(:destroy).with_foreign_key(:module_instance_id) }
    it { should have_many(:architectures).class_name('Metasploit::Cache::Architecture').through(:module_architectures) }
    it { should have_many(:authors).class_name('Metasploit::Cache::Author').through(:module_authors) }
    it { should have_many(:authorities).class_name('Metasploit::Cache::Authority').through(:references) }
    it { should belong_to(:default_action).class_name('Metasploit::Cache::Module::Action') }
    it { should belong_to(:default_target).class_name('Metasploit::Cache::Module::Target') }
    it { should have_many(:email_addresses).class_name('Metasploit::Cache::EmailAddress').through(:module_authors) }
    it { should have_many(:module_architectures).class_name('Metasploit::Cache::Module::Architecture').dependent(:destroy).with_foreign_key(:module_instance_id) }
    it { should have_many(:module_authors).class_name('Metasploit::Cache::Module::Author').dependent(:destroy).with_foreign_key(:module_instance_id) }
    it { should belong_to(:module_class).class_name('Metasploit::Cache::Module::Class') }
    it { should have_many(:module_platforms).class_name('Metasploit::Cache::Module::Platform').dependent(:destroy).with_foreign_key(:module_instance_id) }
    it { should have_many(:module_references).class_name('Metasploit::Cache::Module::Reference').dependent(:destroy).with_foreign_key(:module_instance_id) }
    it { should have_many(:platforms).class_name('Metasploit::Cache::Platform').through(:module_platforms) }
    it { should have_one(:rank).class_name('Metasploit::Cache::Module::Rank').through(:module_class) }
    it { should have_many(:references).class_name('Metasploit::Cache::Reference').through(:module_references) }
    it { should have_many(:targets).class_name('Metasploit::Cache::Module::Target').dependent(:destroy).with_foreign_key(:module_instance_id) }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:default_action_id).of_type(:integer).with_options(:null => true) }
      it { should have_db_column(:default_target_id).of_type(:integer).with_options(:null => true) }
      it { should have_db_column(:description).of_type(:text).with_options(:null => false) }
      it { should have_db_column(:disclosed_on).of_type(:date).with_options(:null => true) }
      it { should have_db_column(:license).of_type(:string).with_options(:null => false) }
      it { should have_db_column(:module_class_id).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:name).of_type(:text).with_options(:null => false) }
      it { should have_db_column(:privileged).of_type(:boolean).with_options(:null => false) }
      it { should have_db_column(:stance).of_type(:string).with_options(:null => true) }
    end

    context 'indices' do
      it { should have_db_index(:default_action_id).unique(true) }
      it { should have_db_index(:default_target_id).unique(true) }
      it { should have_db_index(:module_class_id).unique(true) }
    end
  end

  context 'factories' do
    context :metasploit_cache_module_instance do
      subject(:metasploit_cache_module_instance) do
        FactoryGirl.build(:metasploit_cache_module_instance)
      end

      it { should be_valid }

      context 'Metasploit::Cache::Module::Class#module_type' do
        subject(:metasploit_cache_module_class) do
          FactoryGirl.build(
              :metasploit_cache_module_instance,
              module_class: module_class
          )
        end

        let(:module_class) do
          FactoryGirl.create(
              :metasploit_cache_module_class,
              :module_type => module_type
          )
        end

        context 'with auxiliary' do
          let(:module_type) do
            'auxiliary'
          end

          it { should be_valid }

          it { should allow_attribute :actions }
          it { should_not allow_attribute :module_architectures }
          it { should_not allow_attribute :module_platforms }
          it { should allow_attribute :module_references }
          it { should_not allow_attribute :targets }

          it { should be_stanced }
        end

        context 'with encoder' do
          let(:module_type) do
            'encoder'
          end

          it { should be_valid }

          it { should_not allow_attribute :actions }
          it { should allow_attribute :module_architectures }
          it { should_not allow_attribute :module_platforms }
          it { should_not allow_attribute :module_references }
          it { should_not allow_attribute :targets }

          it { should_not be_stanced }
        end

        context 'with exploit' do
          let(:module_type) do
            'exploit'
          end

          it { should be_valid }

          it { should_not allow_attribute :actions }
          it { should allow_attribute :module_architectures }
          it { should allow_attribute :module_platforms }
          it { should allow_attribute :module_references }
          it { should allow_attribute :targets }

          it { should be_stanced }
        end

        context 'with nop' do
          let(:module_type) do
            'nop'
          end

          it { should be_valid }

          it { should_not allow_attribute :actions }
          it { should allow_attribute :module_architectures }
          it { should_not allow_attribute :module_platforms }
          it { should_not allow_attribute :module_references }
          it { should_not allow_attribute :targets }

          it { should_not be_stanced }
        end

        context 'with payload' do
          let(:module_type) do
            'payload'
          end

          it { should be_valid }

          it { should_not allow_attribute :actions }
          it { should allow_attribute :module_architectures }
          it { should allow_attribute :module_platforms }
          it { should_not allow_attribute :module_references }
          it { should_not allow_attribute :targets }

          it { should_not be_stanced }
        end

        context 'with post' do
          let(:module_type) do
            'post'
          end

          it { should be_valid }

          it { should allow_attribute :actions }
          it { should allow_attribute :module_architectures }
          it { should allow_attribute :module_platforms }
          it { should allow_attribute :module_references }
          it { should_not allow_attribute :targets }

          it { should_not be_stanced }
        end
      end
    end
  end

  context 'scopes' do
    context 'compatible_privilege_with' do
      subject(:compatible_privilege_with) do
        described_class.compatible_privilege_with(module_instance)
      end

      #
      # let!s
      #

      let!(:module_instance) do
        FactoryGirl.create(
            :metasploit_cache_module_instance,
            privileged: privilege
        )
      end

      let!(:privileged) do
        FactoryGirl.create(
            :metasploit_cache_module_instance,
            privileged: true
        )
      end

      let!(:unprivileged) do
        FactoryGirl.create(
            :metasploit_cache_module_instance,
            privileged: false
        )
      end

      context 'with privileged' do
        let(:privilege) do
          true
        end

        it 'includes privileged Metasploit::Cache::Module::Instances' do
          expect(compatible_privilege_with).to include(privileged)
        end

        it 'includes unprivileged Metasploit::Cache::Module::Instances' do
          expect(compatible_privilege_with).to include(unprivileged)
        end
      end

      context 'without privileged' do
        let(:privilege) do
          false
        end

        it 'does not include privileged Metasploit::Cache::Module::Instances' do
          expect(compatible_privilege_with).not_to include(privileged)
        end

        it 'includes unprivileged Metasploit::Cache::Module::Instances' do
          expect(compatible_privilege_with).to include(unprivileged)
        end
      end
    end

    context 'encoders_compatible_with' do
      subject(:encoders_compatible_with) {
        described_class.encoders_compatible_with(payload_instance)
      }

      #
      # lets
      #

      let(:first_payload_architecture) {
        Metasploit::Cache::Architecture.where(abbreviation: 'x86').first
      }

      let(:fully_matched_encoder_class) {
        FactoryGirl.create(
            :metasploit_cache_module_class,
            module_type: 'encoder'
        )
      }

      let(:partially_matched_encoder_architecture) {
        Metasploit::Cache::Architecture.where(abbreviation: 'ppc64').first
      }

      let(:partially_matched_encoder_class) {
        FactoryGirl.create(
            :metasploit_cache_module_class,
            module_type: 'encoder'
        )
      }

      let(:payload_class) {
        FactoryGirl.create(
            :metasploit_cache_module_class,
            module_type: 'payload'
        )
      }

      let(:second_payload_architecture) {
        Metasploit::Cache::Architecture.where(abbreviation: 'x86_64').first
      }

      let(:unmatched_encoder_architecture) {
        Metasploit::Cache::Architecture.where(abbreviation: 'ppc').first
      }

      let(:unmatched_encoder_class) {
        FactoryGirl.create(
            :metasploit_cache_module_class,
            module_type: 'encoder'
        )
      }

      #
      # let!s
      #

      let!(:fully_matched_encoder_instance) {
        FactoryGirl.build(
            :metasploit_cache_module_instance,
            # zero as it will be filed in manually
            module_architectures_length: 0,
            module_class: fully_matched_encoder_class
        ).tap { |module_instance|
          module_instance.module_architectures.build(architecture: first_payload_architecture)
          module_instance.module_architectures.build(architecture: second_payload_architecture)

          Metasploit::Cache::Module::Instance::Spec::Template.write!(module_instance: module_instance)

          module_instance.save!
        }
      }

      let!(:partially_matched_encoder_instance) {
        FactoryGirl.build(
            :metasploit_cache_module_instance,
            # zero as it will be filed in manually
            module_architectures_length: 0,
            module_class: partially_matched_encoder_class
        ).tap { |module_instance|
          module_instance.module_architectures.build(architecture: partially_matched_encoder_architecture)
          module_instance.module_architectures.build(architecture: second_payload_architecture)

          Metasploit::Cache::Module::Instance::Spec::Template.write!(module_instance: module_instance)

          module_instance.save!
        }
      }

      let!(:payload_instance) {
        FactoryGirl.build(
            :metasploit_cache_module_instance,
            # zero as it will be filed in manually
            module_architectures_length: 0,
            module_class: payload_class
        ).tap { |module_instance|
          module_instance.module_architectures.build(architecture: first_payload_architecture)
          module_instance.module_architectures.build(architecture: second_payload_architecture)

          Metasploit::Cache::Module::Instance::Spec::Template.write!(module_instance: module_instance)

          module_instance.save!
        }
      }

      let!(:unmatched_encoder_instance) {
        FactoryGirl.build(
            :metasploit_cache_module_instance,
            # zero as it will be filed in manually
            module_architectures_length: 0,
            module_class: unmatched_encoder_class
        ).tap { |module_instance|
          module_instance.module_architectures  .build(architecture: unmatched_encoder_architecture)

          Metasploit::Cache::Module::Instance::Spec::Template.write!(module_instance: module_instance)

          module_instance.save!
        }
      }

      it "matches Metasploit::Cache::Module::Instance with Metasploit::Cache::Module::Class#module_type 'encoder'" do
        expect(encoders_compatible_with).not_to be_empty

        expect(
            encoders_compatible_with.all? { |module_instance|
              module_instance.module_class.module_type == 'encoder'
            }
        ).to eq(true)
      end

      it 'matches encoders with same architectures' do
        expect(encoders_compatible_with).to include(fully_matched_encoder_instance)
      end

      it 'matches encoders with some architectures overlapping' do
        expect(encoders_compatible_with).to include(partially_matched_encoder_instance)
      end

      it 'does not match encoders with different architecture' do
        expect(encoders_compatible_with).not_to include(unmatched_encoder_instance)
      end

      it 'is ordered by rank' do
        expected_encoders = [fully_matched_encoder_instance, partially_matched_encoder_instance].sort_by { |module_instance|
          module_instance.rank.number
        }.reverse # reverse to make descending

        expect(encoders_compatible_with).to eq(expected_encoders)
      end
    end

    context 'intersecting_architecture_abbreviations' do
      subject(:intersecting_architecture_abbreviations) do
        described_class.intersecting_architecture_abbreviations(architecture_abbreviation)
      end

      let(:other_architecture) do
        Metasploit::Cache::Architecture.where(abbreviation: other_architecture_abbreviation).first
      end

      let(:architecture_abbreviation) do
        FactoryGirl.generate :metasploit_cache_architecture_abbreviation
      end

      let(:other_module_class) do
        FactoryGirl.create(
            :metasploit_cache_module_class,
            module_type: 'payload'
        )
      end

      #
      # let!s
      #

      let!(:other_module_instance) do
        FactoryGirl.build(
            :metasploit_cache_module_instance,
            module_architectures_length: 0,
            module_class: other_module_class
        ).tap { |module_instance|
          module_architecture = module_instance.module_architectures.build
          module_architecture.architecture = other_architecture

          module_instance.save!
        }
      end

      context 'with intersection' do
        #
        # lets
        #

        let(:other_architecture_abbreviation) do
          architecture_abbreviation
        end

        it 'includes the Metasploit::Cache::Module::Instance' do
          expect(intersecting_architecture_abbreviations).to include(other_module_instance)
        end
      end

      context 'without intersection' do
        let(:other_architecture_abbreviation) do
          FactoryGirl.generate :metasploit_cache_architecture_abbreviation
        end

        it 'does not include the Metasploit::Cache::Module::Instance' do
          expect(intersecting_architecture_abbreviations).not_to include(other_module_instance)
        end
      end
    end

    context 'intersecting_architectures_with' do
      subject(:intersecting_architectures_with) do
        described_class.intersecting_architectures_with(architectured)
      end

      context 'with Metasploit::Cache::Module::Instance' do
        let(:architectured) do
          FactoryGirl.create(
              :metasploit_cache_module_instance,
              module_class: module_class
          )
        end

        let(:module_class) do
          FactoryGirl.create(
              :metasploit_cache_module_class,
              module_type: 'payload'
          )
        end

        it 'selects abbreviation from Metasploit::Cache::Module::Instance#architectures' do
          expect(architectured.architectures).to receive(:select).with(:abbreviation).and_call_original

          intersecting_architectures_with
        end

        it 'calls intersecting_architecture_abbreviations with Arel::SelectManager' do
          expect(described_class).to receive(:intersecting_architecture_abbreviations).with(
                                         an_instance_of(Arel::SelectManager)
                                     )

          intersecting_architectures_with
        end
      end

      context 'with Metasploit::Cache::Module::Target' do
        #
        # lets
        #

        let(:architecture) do
          FactoryGirl.generate :metasploit_cache_architecture
        end

        let(:other_module_class) do
          FactoryGirl.create(
              :metasploit_cache_module_class,
              module_type: 'payload'
          )
        end

        let(:other_architecture) do
          FactoryGirl.generate :metasploit_cache_architecture
        end

        #
        # let!s
        #

        let!(:architectured) do
          FactoryGirl.build(
              :metasploit_cache_module_target,
              target_architectures_length: 0
          ).tap { |module_target|
            target_architecture = module_target.target_architectures.build
            target_architecture.architecture = architecture

            module_instance = module_target.module_instance
            module_architecture = module_instance.module_architectures.build
            module_architecture.architecture = architecture

            module_target.save!
          }
        end

        let!(:other_module_instance) do
          FactoryGirl.build(
              :metasploit_cache_module_instance,
              module_architectures_length: 0,
              module_class: other_module_class
          ).tap { |module_instance|
            module_architecture = module_instance.module_architectures.build
            module_architecture.architecture = other_architecture

            module_instance.save!
          }
        end

        it 'selects abbreviation from Metasploit::Cache::Module::Target#architectures' do
          expect(architectured.architectures).to receive(:select).with(:abbreviation).and_call_original

          intersecting_architectures_with
        end

        it 'calls intersecting_architecture_abbreviations with Arel::SelectManager to perform a subselect' do
          expect(described_class).to receive(:intersecting_architecture_abbreviations).with(
                                         an_instance_of(Arel::SelectManager)
                                     ).and_call_original

          intersecting_architectures_with
        end

        context 'with intersection' do
          let(:other_architecture) do
            architecture
          end

          it 'includes the Metasploit::Cache::Module::Instance' do
            expect(intersecting_architectures_with).to include(other_module_instance)
          end
        end

        context 'without intersection' do
          let(:other_architecture) do
            FactoryGirl.generate :metasploit_cache_architecture
          end

          it 'does not include the Metasploit::Cache::Module::Instance' do
            expect(intersecting_architectures_with).not_to include(other_module_instance)
          end
        end
      end
    end

    context 'intersecting_platforms' do
      include_context 'platforms'

      subject(:intersecting_platforms) do
        described_class.intersecting_platforms(platforms)
      end

      let(:platforms) do
        [
            platform
        ]
      end

      it_should_behave_like 'intersecting platforms'
    end

    context 'intersecting_platform_fully_qualified_names' do
      include_context 'platforms'

      subject(:intersecting_platform_fully_qualified_names) do
        described_class.intersecting_platform_fully_qualified_names(platform_fully_qualified_names)
      end

      let(:other_platform_fully_qualified_name) do
        platform_fully_qualified_name
      end

      let(:platform_fully_qualified_names) do
        platform_fully_qualified_name
      end

      it_should_behave_like 'intersecting platforms'

      it 'calls intersecting_platforms with ActiveRecord::Relation<Metasploit::Cache::Platform>' do
        expect(described_class).to receive(:intersecting_platforms).with(an_instance_of(ActiveRecord::Relation))

        intersecting_platform_fully_qualified_names
      end

      it 'calls intersecting_platforms with Metasploit::Cache::Platforms with platform_fully_qualified_names' do
        expect(described_class).to receive(
                                       :intersecting_platforms
                                   ).with(
                                       array_including(platform)
                                   ).and_call_original

        intersecting_platform_fully_qualified_names
      end
    end

    context 'intersecting_platforms_with' do
      include_context 'platforms'

      subject(:intersecting_platforms_with) do
        described_class.intersecting_platforms_with(module_target)
      end

      let(:module_target) do
        FactoryGirl.build(
            :metasploit_cache_module_target,
            target_platforms_length: 0
        ).tap { |module_target|
          module_target.target_platforms.build(
              platform: platform
          )

          module_target.module_instance.module_platforms.build(
              platform: platform
          )

          module_target.save!
        }
      end

      let(:other_platform_fully_qualified_name) do
        platform_fully_qualified_name
      end

      it_should_behave_like 'intersecting platforms'

      it 'calls #intersecting_platforms with module_target.platforms' do
        expect(described_class).to receive(
                                       :intersecting_platforms
                                   ).with(
                                       array_including(module_target.platforms.to_a)
                                   ).and_call_original

        intersecting_platforms_with
      end
    end

    context 'payloads_compatible_with' do
      subject(:payloads_compatible_with) do
        described_class.payloads_compatible_with(module_target)
      end

      #
      # lets
      #

      let(:architecture) do
        FactoryGirl.generate :metasploit_cache_architecture
      end

      let(:module_target) do
        FactoryGirl.build(
            :metasploit_cache_module_target,
            target_architectures_length: 0,
            target_platforms_length: 0
        ).tap { |module_target|
          module_target.target_architectures.build(
              architecture: architecture
          )

          module_target.module_instance.module_architectures.build(
              architecture: architecture
          )

          module_target.target_platforms.build(
              platform: platform
          )

          module_target.module_instance.module_platforms.build(
                  platform: platform
          )
        }
      end

      let(:platform) do
        Metasploit::Cache::Platform.where(fully_qualified_name: platform_fully_qualified_name).first
      end

      let(:platform_fully_qualified_name) do
        'Windows XP'
      end

      #
      # Callbacks
      #

      before(:each) do
        module_target.save!
      end

      it "calls with_module_type('payload')" do
        expect(described_class).to receive(:with_module_type).with('payload').and_call_original

        payloads_compatible_with
      end

      it 'calls compatible_privilege_with on the module_target.module_instance' do
        expect(described_class).to receive(:compatible_privilege_with).with(module_target.module_instance).and_call_original

        payloads_compatible_with
      end

      it 'calls intersecting_architectures_with on the module_target' do
        expect(described_class).to receive(:intersecting_architectures_with).with(module_target).and_call_original

        payloads_compatible_with
      end

      it 'calls intersecting_paltforms_with on the module_target' do
        expect(described_class).to receive(:intersecting_platforms_with).with(module_target).and_call_original

        payloads_compatible_with
      end
    end

    context 'nops_compatible_with' do
      subject(:nops_compatible_with) {
        described_class.nops_compatible_with(payload_instance)
      }

      #
      # lets
      #

      let(:first_payload_architecture) {
        Metasploit::Cache::Architecture.where(abbreviation: 'x86').first
      }

      let(:fully_matched_nop_class) {
        FactoryGirl.create(
            :metasploit_cache_module_class,
            module_type: 'nop'
        )
      }

      let(:partially_matched_nop_architecture) {
        Metasploit::Cache::Architecture.where(abbreviation: 'ppc64').first
      }

      let(:partially_matched_nop_class) {
        FactoryGirl.create(
            :metasploit_cache_module_class,
            module_type: 'nop'
        )
      }

      let(:payload_class) {
        FactoryGirl.create(
            :metasploit_cache_module_class,
            module_type: 'payload'
        )
      }

      let(:second_payload_architecture) {
        Metasploit::Cache::Architecture.where(abbreviation: 'x86_64').first
      }

      let(:unmatched_nop_architecture) {
        Metasploit::Cache::Architecture.where(abbreviation: 'ppc').first
      }

      let(:unmatched_nop_class) {
        FactoryGirl.create(
            :metasploit_cache_module_class,
            module_type: 'nop'
        )
      }

      #
      # let!s
      #

      let!(:fully_matched_nop_instance) {
        FactoryGirl.build(
            :metasploit_cache_module_instance,
            # zero as it will be filed in manually
            module_architectures_length: 0,
            module_class: fully_matched_nop_class
        ).tap { |module_instance|
          module_instance.module_architectures.build(architecture: first_payload_architecture)
          module_instance.module_architectures.build(architecture: second_payload_architecture)

          Metasploit::Cache::Module::Instance::Spec::Template.write!(module_instance: module_instance)

          module_instance.save!
        }
      }

      let!(:partially_matched_nop_instance) {
        FactoryGirl.build(
            :metasploit_cache_module_instance,
            # zero as it will be filed in manually
            module_architectures_length: 0,
            module_class: partially_matched_nop_class
        ).tap { |module_instance|
          module_instance.module_architectures.build(architecture: partially_matched_nop_architecture)
          module_instance.module_architectures.build(architecture: second_payload_architecture)

          Metasploit::Cache::Module::Instance::Spec::Template.write!(module_instance: module_instance)

          module_instance.save!
        }
      }

      let!(:payload_instance) {
        FactoryGirl.build(
            :metasploit_cache_module_instance,
            # zero as it will be filed in manually
            module_architectures_length: 0,
            module_class: payload_class
        ).tap { |module_instance|
          module_instance.module_architectures.build(architecture: first_payload_architecture)
          module_instance.module_architectures.build(architecture: second_payload_architecture)

          Metasploit::Cache::Module::Instance::Spec::Template.write!(module_instance: module_instance)

          module_instance.save!
        }
      }

      let!(:unmatched_nop_instance) {
        FactoryGirl.build(
            :metasploit_cache_module_instance,
            # zero as it will be filed in manually
            module_architectures_length: 0,
            module_class: unmatched_nop_class
        ).tap { |module_instance|
          module_instance.module_architectures  .build(architecture: unmatched_nop_architecture)

          Metasploit::Cache::Module::Instance::Spec::Template.write!(module_instance: module_instance)

          module_instance.save!
        }
      }

      it "matches Metasploit::Cache::Module::Instance with Metasploit::Cache::Module::Class#module_type 'nop'" do
        expect(nops_compatible_with).not_to be_empty

        expect(
            nops_compatible_with.all? { |module_instance|
              module_instance.module_class.module_type == 'nop'
            }
        ).to eq(true)
      end

      it 'matches nops with same architectures' do
        expect(nops_compatible_with).to include(fully_matched_nop_instance)
      end

      it 'matches nops with some architectures overlapping' do
        expect(nops_compatible_with).to include(partially_matched_nop_instance)
      end

      it 'does not match nops with different architecture' do
        expect(nops_compatible_with).not_to include(unmatched_nop_instance)
      end

      it 'is ordered by rank' do
        expected_nops = [fully_matched_nop_instance, partially_matched_nop_instance].sort_by { |module_instance|
          module_instance.rank.number
        }.reverse # reverse to make descending

        expect(nops_compatible_with).to eq(expected_nops)
      end
    end
  end

  context 'search' do
    let(:base_class) {
      Metasploit::Cache::Module::Instance
    }

    context 'associations' do
      it_should_behave_like 'search_association', :actions
      it_should_behave_like 'search_association', :architectures
      it_should_behave_like 'search_association', :authorities
      it_should_behave_like 'search_association', :authors
      it_should_behave_like 'search_association', :email_addresses
      it_should_behave_like 'search_association', :module_class
      it_should_behave_like 'search_association', :platforms
      it_should_behave_like 'search_association', :rank
      it_should_behave_like 'search_association', :references
      it_should_behave_like 'search_association', :targets
    end

    context 'attributes' do
      it_should_behave_like 'search_attribute', :description, :type => :string
      it_should_behave_like 'search_attribute', :disclosed_on, :type => :date
      it_should_behave_like 'search_attribute', :license, :type => :string
      it_should_behave_like 'search_attribute', :name, :type => :string
      it_should_behave_like 'search_attribute', :privileged, :type => :boolean
      it_should_behave_like 'search_attribute', :stance, :type => :string
    end

    context 'withs' do
      it_should_behave_like 'search_with',
                            Metasploit::Cache::Search::Operator::Deprecated::App,
                            :name => :app
      it_should_behave_like 'search_with',
                            Metasploit::Cache::Search::Operator::Deprecated::Author,
                            :name => :author
      it_should_behave_like 'search_with',
                            Metasploit::Cache::Search::Operator::Deprecated::Authority,
                            :abbreviation => :bid,
                            :name => :bid
      it_should_behave_like 'search_with',
                            Metasploit::Cache::Search::Operator::Deprecated::Authority,
                            :abbreviation => :cve,
                            :name => :cve
      it_should_behave_like 'search_with',
                            Metasploit::Cache::Search::Operator::Deprecated::Authority,
                            :abbreviation => :edb,
                            :name => :edb
      it_should_behave_like 'search_with',
                            Metasploit::Cache::Search::Operator::Deprecated::Authority,
                            :abbreviation => :osvdb,
                            :name => :osvdb
      it_should_behave_like 'search_with',
                            Metasploit::Cache::Search::Operator::Deprecated::Platform,
                            :name => :os
      it_should_behave_like 'search_with',
                            Metasploit::Cache::Search::Operator::Deprecated::Platform,
                            :name => :platform
      it_should_behave_like 'search_with',
                            Metasploit::Cache::Search::Operator::Deprecated::Ref,
                            :name => :ref
      it_should_behave_like 'search_with',
                            Metasploit::Cache::Search::Operator::Deprecated::Text,
                            :name => :text
    end

    context 'query' do
      it_should_behave_like 'search query with Metasploit::Cache::Search::Operator::Deprecated::App'
      it_should_behave_like 'search query with Metasploit::Cache::Search::Operator::Deprecated::Authority',
                            :formatted_operator => 'bid'
      it_should_behave_like 'search query with Metasploit::Cache::Search::Operator::Deprecated::Authority',
                            :formatted_operator => 'cve'
      it_should_behave_like 'search query', :formatted_operator => 'description'
      it_should_behave_like 'search query', :formatted_operator => 'disclosed_on'
      it_should_behave_like 'search query with Metasploit::Cache::Search::Operator::Deprecated::Authority',
                            :formatted_operator => 'edb'
      it_should_behave_like 'search query', :formatted_operator => 'license'
      it_should_behave_like 'search query', :formatted_operator => 'name'
      it_should_behave_like 'search query', :formatted_operator => 'os'
      it_should_behave_like 'search query with Metasploit::Cache::Search::Operator::Deprecated::Authority',
                            :formatted_operator => 'osvdb'
      it_should_behave_like 'search query', :formatted_operator => 'platform'
      it_should_behave_like 'search query', :formatted_operator => 'privileged'
      it_should_behave_like 'search query', :formatted_operator => 'ref'
      it_should_behave_like 'search query', :formatted_operator => 'stance'
      it_should_behave_like 'search query', :formatted_operator => 'text'

      it_should_behave_like 'search query', :formatted_operator => 'actions.name'

      context 'architectures' do
        it_should_behave_like 'search query', :formatted_operator => 'architectures.abbreviation'
        it_should_behave_like 'search query', :formatted_operator => 'architectures.bits'
        it_should_behave_like 'search query', :formatted_operator => 'architectures.endianness'
        it_should_behave_like 'search query', :formatted_operator => 'architectures.family'
      end

      it_should_behave_like 'search query', :formatted_operator => 'authorities.abbreviation'
      it_should_behave_like 'search query', :formatted_operator => 'authors.name'

      context 'email_addresses' do
        it_should_behave_like 'search query', :formatted_operator => 'email_addresses.domain'
        it_should_behave_like 'search query', :formatted_operator => 'email_addresses.local'
      end

      context 'module_class' do
        it_should_behave_like 'search query', :formatted_operator => 'module_class.full_name'
        it_should_behave_like 'search query', :formatted_operator => 'module_class.module_type'
        it_should_behave_like 'search query', :formatted_operator => 'module_class.payload_type'
        it_should_behave_like 'search query', :formatted_operator => 'module_class.reference_name'
      end

      it_should_behave_like 'search query', :formatted_operator => 'platforms.fully_qualified_name'

      context 'rank' do
        it_should_behave_like 'search query', :formatted_operator => 'rank.name'
        it_should_behave_like 'search query', :formatted_operator => 'rank.number'
      end

      context 'references' do
        it_should_behave_like 'search query', :formatted_operator => 'references.designation'
        it_should_behave_like 'search query', :formatted_operator => 'references.url'
      end

      it_should_behave_like 'search query', :formatted_operator => 'targets.name'
    end
  end

  context 'validations' do
    subject(:module_instance) do
      FactoryGirl.build(
          :metasploit_cache_module_instance,
          module_class: module_class
      )
    end

    let(:module_class) do
      FactoryGirl.create(
          :metasploit_cache_module_class,
          module_type: module_type
      )
    end

    let(:module_type) do
      module_types.sample
    end

    let(:module_types) do
      Metasploit::Cache::Module::Type::ALL
    end

    it { should validate_presence_of :description }
    it { should validate_presence_of :license }
    it { should validate_length_of(:module_authors) }

    it_should_behave_like 'Metasploit::Cache::Module::Instance validates dynamic length of',
                          :actions,
                          factory: :metasploit_cache_module_action,
                          options_by_extreme_by_module_type: {
                              'auxiliary' => {
                                  maximum: {
                                      extreme: Float::INFINITY
                                  },
                                  minimum: {
                                      extreme: 0
                                  }
                              },
                              'encoder' => {
                                  maximum: {
                                      error_type: :wrong_length,
                                      extreme: 0
                                  },
                                  minimum: {
                                      extreme: 0
                                  }
                              },
                              'exploit' => {
                                  maximum: {
                                      error_type: :wrong_length,
                                      extreme: 0
                                  },
                                  minimum: {
                                      extreme: 0
                                  }
                              },
                              'nop' => {
                                  maximum: {
                                      error_type: :wrong_length,
                                      extreme: 0
                                  },
                                  minimum: {
                                      extreme: 0
                                  }
                              },
                              'payload' => {
                                  maximum: {
                                      error_type: :wrong_length,
                                      extreme: 0
                                  },
                                  minimum: {
                                      extreme: 0
                                  }
                              },
                              'post' => {
                                  maximum: {
                                      extreme: Float::INFINITY
                                  },
                                  minimum: {
                                      extreme: 0
                                  }
                              }
                          }

    it_should_behave_like 'Metasploit::Cache::Module::Instance validates dynamic length of',
                          :module_architectures,
                          factory: :metasploit_cache_module_architecture,
                          options_by_extreme_by_module_type: {
                              'auxiliary' => {
                                  maximum: {
                                      error_type: :wrong_length,
                                      extreme: 0
                                  },
                                  minimum: {
                                      extreme: 0
                                  }
                              },
                              'encoder' => {
                                  maximum: {
                                      extreme: Float::INFINITY
                                  },
                                  minimum: {
                                      error_type: :too_short,
                                      extreme: 1
                                  }
                              },
                              'exploit' => {
                                  maximum: {
                                      extreme: Float::INFINITY
                                  },
                                  minimum: {
                                      error_type: :too_short,
                                      extreme: 1
                                  }
                              },
                              'nop' => {
                                  maximum: {
                                      extreme: Float::INFINITY
                                  },
                                  minimum: {
                                      error_type: :too_short,
                                      extreme: 1
                                  }
                              },
                              'payload' => {
                                  maximum: {
                                      extreme: Float::INFINITY
                                  },
                                  minimum: {
                                      error_type: :too_short,
                                      extreme: 1
                                  }
                              },
                              'post' => {
                                  maximum: {
                                      extreme: Float::INFINITY
                                  },
                                  minimum: {
                                      error_type: :too_short,
                                      extreme: 1
                                  }
                              }
                          }

    it_should_behave_like 'Metasploit::Cache::Module::Instance validates dynamic length of',
                          :module_platforms,
                          factory: :metasploit_cache_module_platform,
                          options_by_extreme_by_module_type: {
                              'auxiliary' => {
                                  maximum: {
                                      error_type: :wrong_length,
                                      extreme: 0
                                  },
                                  minimum: {
                                      extreme: 0
                                  }
                              },
                              'encoder' => {
                                  maximum: {
                                      error_type: :wrong_length,
                                      extreme: 0
                                  },
                                  minimum: {
                                      extreme: 0
                                  }
                              },
                              'exploit' => {
                                  maximum: {
                                      extreme: Float::INFINITY
                                  },
                                  minimum: {
                                      error_type: :too_short,
                                      extreme: 1
                                  }
                              },
                              'nop' => {
                                  maximum: {
                                      error_type: :wrong_length,
                                      extreme: 0
                                  },
                                  minimum: {
                                      extreme: 0
                                  }
                              },
                              'payload' => {
                                  maximum: {
                                      extreme: Float::INFINITY
                                  },
                                  minimum: {
                                      error_type: :too_short,
                                      extreme: 1
                                  }
                              },
                              'post' => {
                                  maximum: {
                                      extreme: Float::INFINITY
                                  },
                                  minimum: {
                                      error_type: :too_short,
                                      extreme: 1
                                  }
                              }
                          }

    it_should_behave_like 'Metasploit::Cache::Module::Instance validates dynamic length of',
                          :module_references,
                          factory: :metasploit_cache_module_reference,
                          options_by_extreme_by_module_type: {
                              'auxiliary' => {
                                  maximum: {
                                      extreme: Float::INFINITY,
                                  },
                                  minimum: {
                                      extreme: 0
                                  }
                              },
                              'encoder' => {
                                  maximum: {
                                      error_type: :wrong_length,
                                      extreme: 0
                                  },
                                  minimum: {
                                      extreme: 0
                                  }
                              },
                              'exploit' => {
                                  maximum: {
                                      extreme: Float::INFINITY
                                  },
                                  minimum: {
                                      error_type: :too_short,
                                      extreme: 1
                                  }
                              },
                              'nop' => {
                                  maximum: {
                                      error_type: :wrong_length,
                                      extreme: 0
                                  },
                                  minimum: {
                                      extreme: 0
                                  }
                              },
                              'payload' => {
                                  maximum: {
                                      error_type: :wrong_length,
                                      extreme: 0
                                  },
                                  minimum: {
                                      extreme: 0
                                  }
                              },
                              'post' => {
                                  maximum: {
                                      extreme: Float::INFINITY,
                                  },
                                  minimum: {
                                      extreme: 0
                                  }
                              }
                          }

    it_should_behave_like 'Metasploit::Cache::Module::Instance validates dynamic length of',
                          :targets,
                          factory: :metasploit_cache_module_target,
                          options_by_extreme_by_module_type: {
                              'auxiliary' => {
                                  maximum: {
                                      error_type: :wrong_length,
                                      extreme: 0
                                  },
                                  minimum: {
                                      extreme: 0
                                  }
                              },
                              'encoder' => {
                                  maximum: {
                                      error_type: :wrong_length,
                                      extreme: 0
                                  },
                                  minimum: {
                                      extreme: 0
                                  }
                              },
                              'exploit' => {
                                  maximum: {
                                      extreme: Float::INFINITY
                                  },
                                  minimum: {
                                      error_type: :too_short,
                                      extreme: 1
                                  }
                              },
                              'nop' => {
                                  maximum: {
                                      error_type: :wrong_length,
                                      extreme: 0
                                  },
                                  minimum: {
                                      extreme: 0
                                  }
                              },
                              'payload' => {
                                  maximum: {
                                      error_type: :wrong_length,
                                      extreme: 0
                                  },
                                  minimum: {
                                      extreme: 0
                                  }
                              },
                              'post' => {
                                  maximum: {
                                      error_type: :wrong_length,
                                      extreme: 0
                                  },
                                  minimum: {
                                      extreme: 0
                                  }
                              }
                          }

    context 'validate presence of module_class' do
      before(:each) do
        module_instance.valid?
      end

      context 'with module_class' do
        let(:module_class) do
          FactoryGirl.build(:metasploit_cache_module_class)
        end

        it 'should not record error on module_class' do
          expect(module_instance.errors[:module_class]).to be_empty
        end
      end

      context 'without module_class' do
        let(:module_class) do
          nil
        end

        it 'should record error on module_class' do
          expect(module_instance.errors[:module_class]).to include("can't be blank")
        end
      end
    end

    it { should validate_presence_of :name }

    context 'ensure inclusion of privileged is boolean' do
      let(:error) do
        'is not included in the list'
      end

      before(:each) do
        module_instance.privileged = privileged

        module_instance.valid?
      end

      context 'with nil' do
        let(:privileged) do
          nil
        end

        it 'should record error' do
          expect(module_instance.errors[:privileged]).to include(error)
        end
      end

      context 'with false' do
        let(:privileged) do
          false
        end

        it 'should not record error' do
          expect(module_instance.errors[:privileged]).to be_empty
        end
      end

      context 'with true' do
        let(:privileged) do
          true
        end

        it 'should not record error' do
          expect(module_instance.errors[:privileged]).to be_empty
        end
      end
    end

    context 'stance' do
      context 'module_type' do
        subject(:module_instance) do
          FactoryGirl.build(
              :metasploit_cache_module_instance,
              :module_class => module_class,
              # set by shared examples
              :stance => stance
          )
        end

        let(:stance) do
          nil
        end

        it_should_behave_like 'Metasploit::Cache::Module::Instance is stanced with module_type', 'auxiliary'
        it_should_behave_like 'Metasploit::Cache::Module::Instance is stanced with module_type', 'exploit'

        it_should_behave_like 'Metasploit::Cache::Module::Instance is not stanced with module_type', 'encoder'
        it_should_behave_like 'Metasploit::Cache::Module::Instance is not stanced with module_type', 'nop'
        it_should_behave_like 'Metasploit::Cache::Module::Instance is not stanced with module_type', 'payload'
        it_should_behave_like 'Metasploit::Cache::Module::Instance is not stanced with module_type', 'post'
      end
    end

    context 'with allows?(:targets)' do
      let(:module_instance) do
        FactoryGirl.build(
            :metasploit_cache_module_instance,
            module_class: module_class,
            # create targets manually to control the number of target architectures and target platforms
            targets_length: 0
        ).tap { |module_instance|
          FactoryGirl.build(
              :metasploit_cache_module_target,
              module_instance: module_instance,
              # need to restrict to 1 architecture and platform to ensure there is an extra architecture or platform
              # available.
              target_architectures_length: 1,
              target_platforms_length: 1
          )
        }
      end

      let(:module_types) do
        Metasploit::Cache::Module::Instance.module_types_that_allow(:targets)
      end

      context '#architectures errors' do
        subject(:architectures_errors) do
          module_instance.errors[:architectures]
        end

        context '#architectures_from_targets' do
          context 'with same architectures' do
            before(:each) do
              module_instance.valid?
            end

            it { should be_empty }
          end

          context 'without same architectures' do
            context 'with extra architectures' do
              #
              # Lets
              #

              let(:error) do
                I18n.translate(
                    'metasploit.model.errors.models.metasploit/cache/module/instance.attributes.architectures.extra',
                    extra: human_architecture_set
                )
              end

              let(:expected_architecture_set) do
                module_instance.targets.each_with_object(Set.new) do |module_target, set|
                  module_target.target_architectures.each do |target_architecture|
                    set.add target_architecture.architecture
                  end
                end
              end

              let(:extra_architecture) do
                extra_architectures.sample
              end

              let(:extra_architectures) do
                Metasploit::Cache::Architecture.all - expected_architecture_set.to_a
              end

              let(:human_architecture_set) do
                "{#{extra_architecture.abbreviation}}"
              end

              #
              # Callbacks
              #

              before(:each) do
                module_instance.module_architectures <<  FactoryGirl.build(
                    :metasploit_cache_module_architecture,
                    architecture: extra_architecture,
                    module_instance: module_instance
                )

                module_instance.valid?
              end

              it 'includes extra error' do
                expect(architectures_errors).to include(error)
              end
            end

            context 'with missing architectures' do
              #
              # Lets
              #

              let(:error) do
                I18n.translate(
                    'metasploit.model.errors.models.metasploit/cache/module/instance.attributes.architectures.missing',
                    missing: human_architecture_set
                )
              end

              let(:human_architecture_set) do
                "{#{missing_architecture.abbreviation}}"
              end

              let(:missing_architecture) do
                missing_module_architecture.architecture
              end

              let(:missing_module_architecture) do
                module_instance.module_architectures.sample
              end

              #
              # Callbacks
              #

              before(:each) do
                module_instance.module_architectures.reject! { |module_architecture|
                  module_architecture == missing_module_architecture
                }

                module_instance.valid?
              end

              it 'includes missing error' do
                expect(architectures_errors).to include(error)
              end
            end
          end
        end
      end

      context '#platforms errors' do
        subject(:platforms_errors) do
          module_instance.errors[:platforms]
        end

        context '#platforms_from_targets' do
          context 'with same platforms' do
            before(:each) do
              module_instance.valid?
            end

            it { should be_empty }
          end

          context 'without same platforms' do
            context 'with extra platforms' do
              #
              # Lets
              #

              let(:error) do
                I18n.translate(
                    'metasploit.model.errors.models.metasploit/cache/module/instance.attributes.platforms.extra',
                    extra: human_platform_set
                )
              end

              let(:expected_platform_set) do
                module_instance.targets.each_with_object(Set.new) do |module_target, set|
                  module_target.target_platforms.each do |target_platform|
                    set.add target_platform.platform
                  end
                end
              end

              let(:extra_platform) do
                extra_platforms.sample
              end

              let(:extra_platforms) do
                Metasploit::Cache::Platform.all - expected_platform_set.to_a
              end

              let(:human_platform_set) do
                "{#{extra_platform.fully_qualified_name}}"
              end

              #
              # Callbacks
              #

              before(:each) do
                module_instance.module_platforms <<  FactoryGirl.build(
                    :metasploit_cache_module_platform,
                    platform: extra_platform,
                    module_instance: module_instance
                )

                module_instance.valid?
              end

              it 'includes extra error' do
                expect(platforms_errors).to include(error)
              end
            end

            context 'with missing platforms' do
              #
              # Lets
              #

              let(:error) do
                I18n.translate(
                    'metasploit.model.errors.models.metasploit/cache/module/instance.attributes.platforms.missing',
                    missing: human_platform_set
                )
              end

              let(:human_platform_set) do
                "{#{missing_platform.fully_qualified_name}}"
              end

              let(:missing_platform) do
                missing_module_platform.platform
              end

              let(:missing_module_platform) do
                module_instance.module_platforms.sample
              end

              #
              # Callbacks
              #

              before(:each) do
                module_instance.module_platforms.reject! { |module_platform|
                  module_platform == missing_module_platform
                }

                module_instance.valid?
              end

              it 'includes missing error' do
                expect(platforms_errors).to include(error)
              end
            end
          end
        end
      end
    end
  end

  context '.allows?' do
    subject(:allows?) {
      described_class.allows?(options)
    }

    #
    # lets
    #

    let(:options) {
      # made up option values so dynamic_length_validation_options can be faked.
      {
          attribute: :attribute,
          module_type: :module_type
      }
    }

    #
    # Callbacks
    #

    before(:each) do
      expect(described_class).to receive(:dynamic_length_validation_options)
                                     .with(options)
                                     .and_return(dynamic_length_validation_options)
    end

    context 'with :is' do
      let(:dynamic_length_validation_options) {
        {
            is: is
        }
      }

      context '0' do
        let(:is) {
          0
        }

        it { is_expected.to eq(false) }
      end

      context '> 0' do
        let(:is) {
          1
        }

        it { is_expected.to eq(true) }
      end
    end

    context 'without :is' do
      context 'with :maximum' do
        let(:dynamic_length_validation_options) {
          {
              maximum: maximum
          }
        }

        context '0' do
          let(:maximum) {
            0
          }

          it { is_expected.to eq(false) }
        end

        context '> 0' do
          let(:maximum) {
            1
          }

          it { is_expected.to eq(true) }
        end
      end

      context 'without :maximum' do
        let(:dynamic_length_validation_options) {
          {}
        }

        it { is_expected.to eq(true) }
      end
    end
  end

  context '.module_types_that_allow' do
    subject(:module_types_that_allow) do
      described_class.module_types_that_allow(attribute)
    end

    context 'with actions' do
      let(:attribute) do
        :actions
      end

      it { should include 'auxiliary' }
      it { should_not include 'encoder' }
      it { should_not include 'exploit' }
      it { should_not include 'nop' }
      it { should_not include 'payload' }
      it { should include 'post' }
    end

    context 'with module_architectures' do
      let(:attribute) do
        :module_architectures
      end

      it { should_not include 'auxiliary' }
      it { should include 'encoder' }
      it { should include 'exploit' }
      it { should include 'nop' }
      it { should include 'payload' }
      it { should include 'post' }
    end

    context 'with module_platforms' do
      let(:attribute) do
        :module_platforms
      end

      it { should_not include 'auxiliary' }
      it { should_not include 'encoder' }
      it { should include 'exploit' }
      it { should_not include 'nop' }
      it { should include 'payload' }
      it { should include 'post' }
    end

    context 'with module_references' do
      let(:attribute) do
        :module_references
      end

      it { should include 'auxiliary' }
      it { should_not include 'encoder' }
      it { should include 'exploit' }
      it { should_not include 'nop' }
      it { should_not include 'payload' }
      it { should include 'post' }
    end

    context 'with targets' do
      let(:attribute) do
        :targets
      end

      it { should_not include 'auxiliary' }
      it { should_not include 'encoder' }
      it { should include 'exploit' }
      it { should_not include 'nop' }
      it { should_not include 'payload' }
      it { should_not include 'post' }
    end

    context 'DYNAMIC_LENGTH_VALIDATION_OPTIONS_BY_MODULE_TYPE_BY_ATTRIBUTE' do
      let(:attribute) do
        :attribute
      end

      let(:module_type) do
        FactoryGirl.generate :metasploit_cache_module_type
      end

      before(:each) do
        expect(described_class::DYNAMIC_LENGTH_VALIDATION_OPTIONS_BY_MODULE_TYPE_BY_ATTRIBUTE).to receive(:fetch).with(
                                                                                                      attribute
                                                                                                  ).and_return(
                                                                                                      dynamic_length_validation_options_by_module_type
                                                                                                  )
      end

      context 'with :is' do
        let(:dynamic_length_validation_options_by_module_type) do
          {
              module_type => {
                  is: is
              }
          }
        end

        context '> 0' do
          let(:is) do
            1
          end

          it 'includes module type' do
            expect(module_types_that_allow).to include(module_type)
          end
        end

        context '<= 0' do
          let(:is) do
            0
          end

          it 'does not include module type' do
            expect(module_types_that_allow).not_to include(module_type)
          end
        end
      end

      context 'without :is' do
        context 'with :maximum' do
          let(:dynamic_length_validation_options_by_module_type) do
            {
                module_type => {
                    maximum: maximum
                }
            }
          end

          context '> 0' do
            let(:maximum) do
              1
            end

            it 'includes module type' do
              expect(module_types_that_allow).to include(module_type)
            end
          end

          context '<= 0' do
            let(:maximum) do
              0
            end

            it 'does not include module type' do
              expect(module_types_that_allow).not_to include(module_type)
            end
          end

        end

        context 'without :maximum' do
          let(:dynamic_length_validation_options_by_module_type) do
            {
                module_type => {}
            }
          end

          it 'includes module type' do
            expect(module_types_that_allow).to include(module_type)
          end
        end
      end
    end
  end

  context '#allows?' do
    subject(:allows?) do
      module_instance.allows?(attribute)
    end

    let(:attribute) do
      double('Attribute')
    end

    before(:each) do
      # can't set module_type in module_class factory because module_class would be invalid and not create then
      module_instance.module_class.module_type = module_type
    end

    context 'with valid #module_type' do
      let(:module_type) do
        FactoryGirl.generate :metasploit_cache_module_type
      end

      it 'should call allows? on class' do
        # memoize module_instance first so it's calls to allows? do not trigger the should_receive
        module_instance

        expect(described_class).to receive(:allows?).with(
                                       hash_including(
                                           attribute: attribute,
                                           module_type: module_type
                                       )
                                   )

        allows?
      end
    end

    context 'without valid #module_type' do
      let(:module_type) do
        'invalid_module_type'
      end

      it { is_expected.to eq(false) }
    end
  end

  context '#dynamic_length_validation_options' do
    subject(:dynamic_length_validation_options) do
      module_instance.dynamic_length_validation_options(attribute)
    end

    let(:attribute) do
      attributes.sample
    end

    let(:attributes) do
      [
          :actions,
          :module_architectures,
          :module_platforms,
          :module_references,
          :targets
      ]
    end

    before(:each) do
      # can't be set on :metasploit_cache_module_class because module_class would fail to create then.
      module_instance.module_class.module_type = module_type
    end

    context 'with valid #module_type' do
      let(:module_type) do
        FactoryGirl.generate :metasploit_cache_module_type
      end

      it 'should call dynamic_length_validation_options on class' do
        expect(described_class).to receive(:dynamic_length_validation_options).with(
                                       hash_including(
                                           attribute: attribute,
                                           module_type: module_type
                                       )
                                   )

        dynamic_length_validation_options
      end
    end

    context 'without valid #module_type' do
      let(:module_type) do
        'invalid_module_type'
      end

      it { should == {} }
    end
  end

  context '#module_type' do
    subject(:module_type) do
      module_instance.module_type
    end

    context 'with #module_class' do
      it 'should delegate to #module_type on #module_class' do
        expected_module_type = double('Expected #module_type')
        expect(module_instance.module_class).to receive(:module_type).and_return(expected_module_type)

        expect(module_type).to eq(expected_module_type)
      end
    end

    context 'without #module_class' do
      before(:each) do
        module_instance.module_class = nil
      end

      it { should be_nil }
    end
  end

  context '#stanced?' do
    subject(:stanced?) do
      module_instance.stanced?
    end

    before(:each) do
      # can't set module_type on module_class factory because it won't pass validations then
      module_instance.module_class.module_type = module_type
    end

    context 'with valid #module_type' do
      let(:module_type) do
        FactoryGirl.generate :metasploit_cache_module_type
      end

      it 'should call stanced? on class' do
        expect(described_class).to receive(:stanced?).with(module_type)

        stanced?
      end
    end

    context 'without valid #module_type' do
      let(:module_type) do
        'invalid_module_type'
      end

      it { is_expected.to eq(false) }
    end
  end

  context '#targets' do
    subject(:targets) do
      module_instance.targets
    end

    context 'with unsaved module_instance' do
      let(:module_instance) do
        FactoryGirl.build(
            :metasploit_cache_module_instance,
            module_class: module_class
        )
      end

      let(:module_class) do
        FactoryGirl.create(
            :metasploit_cache_module_class,
            module_type: module_type
        )
      end

      let(:module_type) do
        module_types.sample
      end

      let(:module_types) do
        Metasploit::Cache::Module::Instance.module_types_that_allow(:targets)
      end

      context 'built without :module_instance' do
        subject(:module_target) do
          targets.build(
              name: name
          )
        end

        let(:name) do
          FactoryGirl.generate :metasploit_cache_module_target_name
        end

        context '#module_instance' do
          subject(:module_target_module_instance) do
            module_target.module_instance
          end

          it 'should be the original module instance' do
            expect(module_target_module_instance).to eq(module_instance)
          end
        end
      end
    end
  end
end
