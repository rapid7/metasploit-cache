RSpec.describe Metasploit::Cache::Module::Instance::Load, type: :model do
  include_context 'Metasploit::Cache::Spec::Unload.unload'

  let(:logger) {
    ActiveSupport::TaggedLogging.new(
        Logger.new(log_string_io)
    )
  }

  let(:log_string_io) {
    StringIO.new
  }

  context 'validations' do
    let(:module_instance_load) {
      described_class.new
    }

    let(:error) {
      I18n.translate!('errors.messages.blank')
    }

    it 'validates presence of #module_instance' do
      module_instance_load.module_instance = nil

      expect(module_instance_load).not_to be_valid
      expect(module_instance_load.errors[:module_instance]).to include(error)
    end

    it 'validates presence of #metasploit_module_class' do
      module_instance_load.metasploit_module_class = nil

      expect(module_instance_load).not_to be_valid
      expect(module_instance_load.errors[:metasploit_module_class]).to include(error)
    end

    it 'validates presence of #logger' do
      module_instance_load.logger = nil

      expect(module_instance_load).not_to be_valid
      expect(module_instance_load.errors[:logger]).to include(error)
    end

    context 'on #metasploit_module_instance' do
      context 'presence' do
        #
        # lets
        #

        let(:error) {
          I18n.translate!('errors.messages.blank')
        }

        #
        # Callbacks
        #

        before(:each) do
          allow(module_instance_load).to receive(
                                                :metasploit_module_instance
                                            ).and_return(
                                                metasploit_module_instance
                                            )

          module_instance_load.valid?(validation_context)
        end

        context 'with :loading validation context' do
          let(:validation_context) {
            :loading
          }

          context 'with nil' do
            let(:metasploit_module_instance) {
              nil
            }

            it 'does not add error on :metasploit_module_instance' do
              expect(module_instance_load.errors[:module_metasploit_module_instance]).not_to include(error)
            end
          end
        end

        context 'without :loading validation context' do
          let(:validation_context) {
            nil
          }

          context 'with nil' do
            let(:metasploit_module_instance) {
              nil
            }

            it 'adds error on :metasploit_module_instance' do
              expect(module_instance_load.errors[:metasploit_module_instance]).to include(error)
            end
          end
        end
      end
    end

    context '#metasploit_module_class_new_valid' do
      #
      # lets
      #

      let(:ephemeral_class) {
        Metasploit::Cache::Auxiliary::Instance::Ephemeral
      }

      let(:module_instance) {
        FactoryGirl.build(:metasploit_cache_auxiliary_instance)
      }

      let(:module_instance_load) {
        described_class.new(
            ephemeral_class: ephemeral_class,
            module_instance: module_instance,
            metasploit_module_class: metasploit_module_class,
            logger: logger
        )
      }

      let(:metasploit_module_class) {
        Class.new.tap { |klass|
          actions = module_instance.actions.map { |action|
            double("Metasploit Module Action", name: action.name)
          }

          klass.send(:define_method, :actions) {
            actions
          }

          authors = module_instance.contributions.map { |contribution|
            double(
                'Metasploit Module author',
                name: contribution.author.name,
                email: contribution.try(:email_address).try(:full)
            )
          }

          klass.send(:define_method, :author) {
            authors
          }

          klass.send(:define_method, :default_action) {}

          description = module_instance.description

          klass.send(:define_method, :description) {
            description
          }

          license = module_instance.licensable_licenses.map(&:license).map(&:abbreviation)

          klass.send(:define_method, :license) {
            license
          }

          name = module_instance.name

          klass.send(:define_method, :name) {
            name
          }

          # Only one branch will be covered
          # :nocov:
          if module_instance.stance == Metasploit::Cache::Module::Stance::PASSIVE
            passive = true
          else
            passive = false
          end
          # :nocov:

          klass.send(:define_method, :passive?) {
            passive
          }
        }
      }

      let(:metasploit_module_class_new_errors) {
        module_instance_load.valid?

        module_instance_load.errors[:metasploit_module_class_new]
      }

      #
      # Callbacks
      #

      before(:each) {
        # memoize with methods with filled values from module_instance.
        metasploit_module_class

        # reset all associations so load has to fill them
        module_instance.actions = []
        module_instance.contributions = []
        module_instance.default_action = nil
        module_instance.description = nil
        module_instance.licensable_licenses = []
        module_instance.name = nil
        module_instance.stance = nil

        allow(module_instance_load).to receive(
                                              :metasploit_module_class_new_exception
                                          ).and_return(
                                              metasploit_module_class_new_exception
                                          )

        module_instance_load.valid?
      }

      context 'with #metasploit_module_class_new_exception' do
        let(:metasploit_module_class_new_exception) {
          Exception.new("error message").tap { |exception|
            exception.set_backtrace(
                [
                    "line 1",
                    "line 2"
                ]
            )
          }
        }

        it 'adds error' do
          expect(metasploit_module_class_new_errors).to include(
                                                                   "Exception error message:\n" \
                                                                   "line 1\n" \
                                                                   "line 2"
                                                               )
        end
      end

      context 'without #metasploit_module_class_new_exception' do
        let(:metasploit_module_class_new_exception) {
          nil
        }

        it 'does not add error' do
          expect(metasploit_module_class_new_errors).to be_empty
        end
      end
    end
  end

  context '#metasploit_module_class_new' do
    subject(:metasploit_module_class_new) {
      module_instance_load.send(:metasploit_module_class_new)
    }

    let(:module_instance_load) {
      described_class.new(
          metasploit_module_class: metasploit_module_class
      )
    }

    let(:metasploit_module_class) {
      double('Metasploit Module class')
    }

    context 'with Exception' do
      before(:each) do
        expect(metasploit_module_class).to receive(:new).and_raise(exception)
      end

      context 'with Interrupt' do
        let(:exception) {
          Interrupt.new
        }

        specify {
          expect {
            metasploit_module_class_new
          }.to raise_error(Interrupt)
        }
      end

      context 'without Interrupt' do
        let(:exception) {
          Exception.new("expected exception")
        }

        it 'does not raise exception' do
          expect {
            metasploit_module_class_new
          }.not_to raise_error
        end

        it { is_expected.to be_nil }

        it 'stores exception in #metasploit_module_class_new_exception' do
          metasploit_module_class_new

          expect(module_instance_load.metasploit_module_class_new_exception).to eq(exception)
        end
      end
    end

    context 'without Exception' do
      #
      # lets
      #

      let(:metasploit_module_instance) {
        double('Metasploit Module instance')
      }

      #
      # Callbacks
      #

      before(:each) do
        allow(metasploit_module_class).to receive(:new).and_return(metasploit_module_instance)
      end

      it 'returns new Metasploit Module instance' do
        expect(metasploit_module_class_new).to eq(metasploit_module_instance)
      end
    end
  end

  context '#metasploit_module_instance' do
    subject(:metasploit_module_instance) {
      module_instance_load.metasploit_module_instance
    }

    context 'with valid for loading' do
      let(:ephemeral_class) {
        Metasploit::Cache::Auxiliary::Instance::Ephemeral
      }

      let(:module_instance_load) {
        described_class.new(
            ephemeral_class: ephemeral_class,
            module_instance: module_instance,
            metasploit_module_class: metasploit_module_class,
            logger: logger
        ).tap { |block_module_instance_load|
          expect(block_module_instance_load).to be_valid(:loading)
        }
      }

      context 'with Metasploit Module instance' do
        context 'with module instance persisted' do
          #
          # lets
          #

          let(:direct_class_load) {
            expect(module_ancestor_load).to be_valid

            Metasploit::Cache::Direct::Class::Load.new(
                direct_class: module_instance.auxiliary_class,
                logger: logger,
                metasploit_module: module_ancestor_load.metasploit_module
            )
          }

          let(:ephemeral_class) {
            Metasploit::Cache::Auxiliary::Instance::Ephemeral
          }

          let(:module_instance) {
            FactoryGirl.build(
                :metasploit_cache_auxiliary_instance,
                :metasploit_cache_auxiliary_instance_auxiliary_class_ancestor_contents
            ).tap { |block_module_instance|
              # Clear out auxiliary attributes and associations so auxiliary_instance_load needs to set them.
              block_module_instance.actions = []
              block_module_instance.contributions = []
              block_module_instance.default_action = nil
              block_module_instance.description = nil
              block_module_instance.licensable_licenses = []
              block_module_instance.name = nil
              block_module_instance.stance = nil
            }
          }

          let(:module_instance_load) {
            expect(direct_class_load).to be_valid

            described_class.new(
                ephemeral_class: ephemeral_class,
                module_instance: module_instance,
                logger: logger,
                metasploit_module_class: direct_class_load.metasploit_class
            )
          }

          let(:module_ancestor_load) {
            Metasploit::Cache::Module::Ancestor::Load.new(
                # This should match the major version number of metasploit-framework
                maximum_version: 4,
                module_ancestor: module_instance.auxiliary_class.ancestor,
                logger: logger
            )
          }

          it 'logs no errors' do
            metasploit_module_instance

            expect(log_string_io.string).to be_blank
          end

          it 'makes valid #module_instance' do
            # Doesn't use change so that be_valid's printing is better
            expect(module_instance).not_to be_valid

            metasploit_module_instance

            expect(module_instance).to be_valid
          end

          it 'persists #module_instance' do
            expect {
              metasploit_module_instance
            }.to change(Metasploit::Cache::Auxiliary::Instance, :count).by(1)
          end

          it 'returns instance of metasploit_module_class' do
            expect(metasploit_module_instance).to be_a direct_class_load.metasploit_class
          end
        end

        context 'without module instance persisted' do
          #
          # lets
          #

          let(:module_instance) {
            direct_class.build_auxiliary_instance
          }

          let(:metasploit_module_class) {
            Class.new do
              #
              # Attributes
              #

              attr_reader :default_action
              attr_reader :description
              attr_reader :license
              attr_reader :name

              #
              # Instance Methods
              #

              def actions
                []
              end

              def author
                []
              end

              def passive?
                true
              end
            end
          }

          #
          # let!s
          #

          let!(:direct_class) {
            FactoryGirl.create(:metasploit_cache_auxiliary_class)
          }

          it 'logs errors' do
            metasploit_module_instance

            expect(log_string_io.string).not_to be_blank
          end

          it { is_expected.to be_nil }
        end
      end

      context 'without Metasploit Module intance' do
        let(:module_instance) {
          Metasploit::Cache::Auxiliary::Instance.new
        }

        let(:metasploit_module_class) {
          Class.new.tap { |klass|
            klass.send(:define_method, :initialize) {
              raise Exception
            }
          }
        }

        it { is_expected.to be_nil }
      end
    end

    context 'without valid for loading' do
      let(:module_instance_load) {
        described_class.new
      }

      it { is_expected.to be_nil }

      it 'is not memoized so it can run when valid for loading' do
        expect(module_instance_load).to receive(:valid?).with(:loading).twice

        module_instance_load.metasploit_module_instance
        module_instance_load.metasploit_module_instance
      end
    end
  end

  context '#loading_context?' do
    subject(:loading_context?) do
      module_instance_load.send(:loading_context?)
    end

    let(:module_instance_load) {
      described_class.new
    }

    context 'with :loading validation_context' do
      it 'should be true' do
        expect(module_instance_load).to receive(:run_validations!) do
          expect(loading_context?).to eq(true)
        end

        module_instance_load.valid?(:loading)
      end
    end

    context 'without validation_context' do
      it 'should be false' do
        expect(module_instance_load).to receive(:run_validations!) do
          expect(loading_context?).to eq(false)
        end

        module_instance_load.valid?
      end
    end
  end

  # :nocov:
  # Can't just use the tag on the context because the below code will still run even if tag is filtered out
  unless Bundler.settings.without.include? 'content'
    context 'metasploit-framework', :content do
      module_path_real_paths = Metasploit::Framework::Engine.paths['modules'].existent_directories

      module_path_real_paths.each do |module_path_real_path|
        module_path_real_pathname = Pathname.new(module_path_real_path)
        module_path_relative_pathname = module_path_real_pathname.relative_path_from(Metasploit::Framework::Engine.root)

        # use relative pathname so that context name is not dependent on build directory
        context module_path_relative_pathname.to_s do
          #
          # Shared examples
          #

          #
          # lets
          #

          let(:module_path) do
            FactoryGirl.create(
                :metasploit_cache_module_path,
                gem: 'metasploit-framework',
                name: 'modules',
                real_path: module_path_real_path
            )
          end

          it_should_behave_like 'Metasploit::Cache::*::Instance::Load from relative_path_prefix',
                                module_path_real_pathname,
                                'auxiliary' do
            let(:direct_class) {
              module_ancestor.build_auxiliary_class
            }

            let(:module_ancestors) {
              module_path.auxiliary_ancestors
            }

            let(:module_instance) {
              direct_class.build_auxiliary_instance
            }

            let(:module_instance_load) {
              described_class.new(
                  ephemeral_class: Metasploit::Cache::Auxiliary::Instance::Ephemeral,
                  module_instance: module_instance,
                  metasploit_module_class: direct_class_load.metasploit_class,
                  logger: logger
              )
            }
          end

          it_should_behave_like 'Metasploit::Cache::*::Instance::Load from relative_path_prefix',
                                module_path_real_pathname,
                                'encoders' do
            let(:direct_class) {
              module_ancestor.build_encoder_class
            }

            let(:module_ancestors) {
              module_path.encoder_ancestors
            }

            let(:module_instance) {
              direct_class.build_encoder_instance
            }

            let(:module_instance_load) {
              described_class.new(
                  ephemeral_class: Metasploit::Cache::Encoder::Instance::Ephemeral,
                  module_instance: module_instance,
                  metasploit_module_class: direct_class_load.metasploit_class,
                  logger: logger
              )
            }
          end
        end
      end
    end
  end
  # :nocov:
end