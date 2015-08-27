RSpec.describe Metasploit::Cache::Module::Instance do
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
    it { should belong_to(:default_target).class_name('Metasploit::Cache::Module::Target') }
    it { should belong_to(:module_class).class_name('Metasploit::Cache::Module::Class') }
    it { should have_one(:rank).class_name('Metasploit::Cache::Module::Rank').through(:module_class) }
    it { should have_many(:targets).class_name('Metasploit::Cache::Module::Target').dependent(:destroy).with_foreign_key(:module_instance_id) }
  end

  context 'database' do
    context 'columns' do
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

          it { should_not allow_attribute :targets }

          it { should be_stanced }
        end

        context 'with encoder' do
          let(:module_type) do
            'encoder'
          end

          it { should be_valid }

          it { should_not allow_attribute :targets }

          it { should_not be_stanced }
        end

        context 'with exploit' do
          let(:module_type) do
            'exploit'
          end

          it { should be_valid }

          it { should allow_attribute :targets }

          it { should be_stanced }
        end

        context 'with nop' do
          let(:module_type) do
            'nop'
          end

          it { should be_valid }

          it { should_not allow_attribute :targets }

          it { should_not be_stanced }
        end

        context 'with payload' do
          let(:module_type) do
            'payload'
          end

          it { should be_valid }

          it { should_not allow_attribute :targets }

          it { should_not be_stanced }
        end

        context 'with post' do
          let(:module_type) do
            'post'
          end

          it { should be_valid }

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
  end

  context 'search' do
    let(:base_class) {
      Metasploit::Cache::Module::Instance
    }

    context 'associations' do
      it_should_behave_like 'search_association', :module_class
      it_should_behave_like 'search_association', :rank
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
                            Metasploit::Cache::Search::Operator::Deprecated::Text,
                            :name => :text
    end

    context 'query' do
      it_should_behave_like 'search query with Metasploit::Cache::Search::Operator::Deprecated::App'
      it_should_behave_like 'search query', :formatted_operator => 'description'
      it_should_behave_like 'search query', :formatted_operator => 'disclosed_on'
      it_should_behave_like 'search query', :formatted_operator => 'license'
      it_should_behave_like 'search query', :formatted_operator => 'name'
      it_should_behave_like 'search query', :formatted_operator => 'privileged'
      it_should_behave_like 'search query', :formatted_operator => 'stance'
      it_should_behave_like 'search query', :formatted_operator => 'text'

      context 'module_class' do
        it_should_behave_like 'search query', :formatted_operator => 'module_class.full_name'
        it_should_behave_like 'search query', :formatted_operator => 'module_class.module_type'
        it_should_behave_like 'search query', :formatted_operator => 'module_class.payload_type'
        it_should_behave_like 'search query', :formatted_operator => 'module_class.reference_name'
      end

      context 'rank' do
        it_should_behave_like 'search query', :formatted_operator => 'rank.name'
        it_should_behave_like 'search query', :formatted_operator => 'rank.number'
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
          :module_platforms,
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
