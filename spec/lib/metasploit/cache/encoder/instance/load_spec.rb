RSpec.describe Metasploit::Cache::Encoder::Instance::Load, type: :model do
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
    let(:encoder_instance_load) {
      described_class.new
    }

    let(:error) {
      I18n.translate!('errors.messages.blank')
    }

    it 'validates presence of #encoder_instance' do
      encoder_instance_load.encoder_instance = nil

      expect(encoder_instance_load).not_to be_valid
      expect(encoder_instance_load.errors[:encoder_instance]).to include(error)
    end

    it 'validates presence of #encoder_metasploit_module_class' do
      encoder_instance_load.encoder_metasploit_module_class = nil

      expect(encoder_instance_load).not_to be_valid
      expect(encoder_instance_load.errors[:encoder_metasploit_module_class]).to include(error)
    end

    it 'validates presence of #logger' do
      encoder_instance_load.logger = nil

      expect(encoder_instance_load).not_to be_valid
      expect(encoder_instance_load.errors[:logger]).to include(error)
    end

    context 'on #encoder_metasploit_module_instance' do
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
          allow(encoder_instance_load).to receive(
            :encoder_metasploit_module_instance
          ).and_return(
            encoder_metasploit_module_instance
          )

          encoder_instance_load.valid?(validation_context)
        end

        context 'with :loading validation context' do
          let(:validation_context) {
            :loading
          }

          context 'with nil' do
            let(:encoder_metasploit_module_instance) {
              nil
            }

            it 'does not add error on :encoder_metasploit_module_instance' do
              expect(encoder_instance_load.errors[:encoder_metasploit_module_instance]).not_to include(error)
            end
          end
        end

        context 'without :loading validation context' do
          let(:validation_context) {
            nil
          }

          context 'with nil' do
            let(:encoder_metasploit_module_instance) {
              nil
            }

            it 'adds error on :encoder_metasploit_module_instance' do
              expect(encoder_instance_load.errors[:encoder_metasploit_module_instance]).to include(error)
            end
          end
        end
      end
    end

    context '#encoder_metasploit_module_class_new_valid' do
      #
      # lets
      #

      let(:encoder_instance) {
        FactoryGirl.build(:metasploit_cache_encoder_instance)
      }

      let(:encoder_instance_load) {
        described_class.new(
            encoder_instance: encoder_instance,
            encoder_metasploit_module_class: encoder_metasploit_module_class,
            logger: logger
        )
      }

      let(:encoder_metasploit_module_class) {
        Class.new.tap { |klass|
          architecture_abbreviations = encoder_instance.architecturable_architectures.map { |architecturable_architecture|
            architecturable_architecture.architecture.abbreviation
          }

          klass.send(:define_method, :arch) {
            architecture_abbreviations
          }

          authors = encoder_instance.contributions.map { |contribution|
            double(
                'Metasploit Module author',
                name: contribution.author.name,
                email: contribution.try(:email_address).try(:full)
            )
          }

          klass.send(:define_method, :author) {
            authors
          }

          description = encoder_instance.description

          klass.send(:define_method, :description) {
            description
          }

          license = encoder_instance.licensable_licenses.map(&:license).map(&:abbreviation)

          klass.send(:define_method, :license) {
            license
          }

          name = encoder_instance.name

          klass.send(:define_method, :name) {
            name
          }

          platforms = encoder_instance.platformable_platforms.map { |platformable_platform|
            double('Platform', realname: platformable_platform.platform.fully_qualified_name)
          }
          platform_list = double('Platform List', platforms: platforms)

          klass.send(:define_method, :platform) {
            platform_list
          }
        }
      }

      let(:encoder_metasploit_module_class_new_errors) {
        encoder_instance_load.valid?

        encoder_instance_load.errors[:encoder_metasploit_module_class_new]
      }

      #
      # Callbacks
      #

      before(:each) {
        # memoize with methods with filled values from encoder_instance.
        encoder_metasploit_module_class

        # reset all associations so load has to fill them
        encoder_instance.architecturable_architectures = []
        encoder_instance.contributions = []
        encoder_instance.description = nil
        encoder_instance.licensable_licenses = []
        encoder_instance.name = nil
        encoder_instance.platformable_platforms = []

        allow(encoder_instance_load).to receive(
          :encoder_metasploit_module_class_new_exception
        ).and_return(
          encoder_metasploit_module_class_new_exception
        )

        encoder_instance_load.valid?
      }

      context 'with #encoder_metasploit_module_class_new_exception' do
        let(:encoder_metasploit_module_class_new_exception) {
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
          expect(encoder_metasploit_module_class_new_errors).to include(
                                                                      "Exception error message:\n" \
                                                                      "line 1\n" \
                                                                      "line 2"
                                                                  )
        end
      end

      context 'without #encoder_metasploit_module_class_new_exception' do
        let(:encoder_metasploit_module_class_new_exception) {
          nil
        }

        it 'does not add error' do
          expect(encoder_metasploit_module_class_new_errors).to be_empty
        end
      end
    end
  end

  context '#encoder_metasploit_module_class_new' do
    subject(:encoder_metasploit_module_class_new) {
      encoder_instance_load.send(:encoder_metasploit_module_class_new)
    }

    let(:encoder_instance_load) {
      described_class.new(
          encoder_metasploit_module_class: encoder_metasploit_module_class
      )
    }

    let(:encoder_metasploit_module_class) {
      double('encoder Metasploit Module class')
    }

    context 'with Exception' do
      before(:each) do
        expect(encoder_metasploit_module_class).to receive(:new).and_raise(exception)
      end

      context 'with Interrupt' do
        let(:exception) {
          Interrupt.new
        }

        specify {
          expect {
            encoder_metasploit_module_class_new
          }.to raise_error(Interrupt)
        }
      end

      context 'without Interrupt' do
        let(:exception) {
          Exception.new("expected exception")
        }

        it 'does not raise exception' do
          expect {
            encoder_metasploit_module_class_new
          }.not_to raise_error
        end

        it { is_expected.to be_nil }

        it 'stores exception in #encoder_metasploit_module_class_new_exception' do
          encoder_metasploit_module_class_new

          expect(encoder_instance_load.encoder_metasploit_module_class_new_exception).to eq(exception)
        end
      end
    end

    context 'without Exception' do
      #
      # lets
      #

      let(:encoder_metasploit_module_instance) {
        double('encoder Metasploit Module instance')
      }

      #
      # Callbacks
      #

      before(:each) do
        allow(encoder_metasploit_module_class).to receive(:new).and_return(encoder_metasploit_module_instance)
      end

      it 'returns new encoder Metasploit Module instance' do
        expect(encoder_metasploit_module_class_new).to eq(encoder_metasploit_module_instance)
      end
    end
  end

  context '#encoder_metasploit_module_instance' do
    subject(:encoder_metasploit_module_instance) {
      encoder_instance_load.encoder_metasploit_module_instance
    }

    context 'with valid for loading' do
      let(:encoder_instance_load) {
        described_class.new(
            encoder_instance: encoder_instance,
            encoder_metasploit_module_class: encoder_metasploit_module_class,
            logger: logger
        )
      }

      context 'with encoder Metasploit Module instance' do
        context 'with encoder instance persisted' do
          #
          # lets
          #

          let(:encoder_instance) {
            FactoryGirl.build(
                :metasploit_cache_encoder_instance,
                :metasploit_cache_encoder_instance_encoder_class_ancestor_contents
            ).tap { |block_encoder_instance|
              # Clear out encoder attributes and associations so encoder_instance_load needs to set them.
              block_encoder_instance.architecturable_architectures = []
              block_encoder_instance.contributions = []
              block_encoder_instance.description = nil
              block_encoder_instance.licensable_licenses = []
              block_encoder_instance.name = nil
              block_encoder_instance.platformable_platforms = []
            }
          }

          let(:encoder_instance_load) {
            expect(direct_class_load).to be_valid

            described_class.new(
                encoder_instance: encoder_instance,
                logger: logger,
                encoder_metasploit_module_class: direct_class_load.metasploit_class
            )
          }

          let(:direct_class_load) {
            expect(module_ancestor_load).to be_valid

            Metasploit::Cache::Direct::Class::Load.new(
                direct_class: encoder_instance.encoder_class,
                logger: logger,
                metasploit_module: module_ancestor_load.metasploit_module
            )
          }

          let(:module_ancestor_load) {
            Metasploit::Cache::Module::Ancestor::Load.new(
                # This should match the major version number of metasploit-framework
                maximum_version: 4,
                module_ancestor: encoder_instance.encoder_class.ancestor,
                logger: logger
            )
          }

          it 'logs no errors' do
            encoder_metasploit_module_instance

            expect(log_string_io.string).to be_blank
          end

          it 'makes valid #encoder_instance' do
            # Doesn't use change so that be_valid's printing is better
            expect(encoder_instance).not_to be_valid

            encoder_metasploit_module_instance

            expect(encoder_instance).to be_valid
          end

          it 'persists #encoder_instance' do
            expect {
              encoder_metasploit_module_instance
            }.to change(Metasploit::Cache::Encoder::Instance, :count).by(1)
          end

          it 'returns instance of encoder_metasploit_module_class' do
            expect(encoder_metasploit_module_instance).to be_a direct_class_load.metasploit_class
          end
        end

        context 'without encoder instance persisted' do
          #
          # lets
          #

          let(:encoder_instance) {
            encoder_class.build_encoder_instance
          }

          let(:encoder_metasploit_module_class) {
            Class.new do
              #
              # Attributes
              #

              attr_reader :description
              attr_reader :license
              attr_reader :name

              #
              # Instance Methods
              #

              def arch
                []
              end

              def author
                []
              end

              def platform
                OpenStruct.new(platforms: [])
              end
            end
          }

          #
          # let!s
          #

          let!(:encoder_class) {
            FactoryGirl.create(:metasploit_cache_encoder_class)
          }

          it 'logs errors' do
            encoder_metasploit_module_instance

            expect(log_string_io.string).not_to be_blank
          end

          it { is_expected.to be_nil }
        end
      end

      context 'without encoder Metasploit Module intance' do
        let(:encoder_instance) {
          Metasploit::Cache::Encoder::Instance.new
        }

        let(:encoder_metasploit_module_class) {
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
      let(:encoder_instance_load) {
        described_class.new
      }

      it { is_expected.to be_nil }

      it 'is not memoized so it can run when valid for loading' do
        expect(encoder_instance_load).to receive(:valid?).with(:loading).twice

        encoder_instance_load.encoder_metasploit_module_instance
        encoder_instance_load.encoder_metasploit_module_instance
      end
    end
  end

  context '#loading_context?' do
    subject(:loading_context?) do
      encoder_instance_load.send(:loading_context?)
    end

    let(:encoder_instance_load) {
      described_class.new
    }

    context 'with :loading validation_context' do
      it 'should be true' do
        expect(encoder_instance_load).to receive(:run_validations!) do
          expect(loading_context?).to eq(true)
        end

        encoder_instance_load.valid?(:loading)
      end
    end

    context 'without validation_context' do
      it 'should be false' do
        expect(encoder_instance_load).to receive(:run_validations!) do
          expect(loading_context?).to eq(false)
        end

        encoder_instance_load.valid?
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
                  encoder_instance: module_instance,
                  encoder_metasploit_module_class: direct_class_load.metasploit_class,
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