RSpec.describe Metasploit::Cache::Payload::Direct::Class::Load do
  include_context 'Metasploit::Cache::Spec::Unload.unload'

  subject(:payload_direct_class_load) {
    described_class.new(
        logger: logger,
        metasploit_module: metasploit_module,
        payload_direct_class: payload_direct_class,
        payload_superclass: Metasploit::Cache::Direct::Class::Superclass
    )
  }

  let(:payload_direct_class) {
    FactoryGirl.build(
        :metasploit_cache_payload_single_class,
        rank: module_rank
    ).tap { |payload_direct_class|
      # Set to nil after build so that template contains a rank, but it's not yet in the record
      payload_direct_class.rank = nil
    }
  }

  let(:module_rank) {
    FactoryGirl.generate :metasploit_cache_module_rank
  }

  let(:logger) {
    ActiveSupport::TaggedLogging.new(
        Logger.new(logger_string_io)
    ).tap { |logger|
      logger.level = Logger::DEBUG
    }
  }

  let(:logger_string_io) {
    StringIO.new
  }

  let(:metasploit_module) {
    Module.new.tap do |metasploit_module|
      metasploit_module.extend Metasploit::Cache::Cacheable
    end
  }

  context 'validations' do
    let(:error) {
      I18n.translate!('errors.messages.blank')
    }

    it 'validates presence of logger' do
      payload_direct_class_load.logger = nil

      expect(payload_direct_class_load).not_to be_valid
      expect(payload_direct_class_load.errors[:logger]).to include(error)
    end

    it 'validates presence of metasploit_module' do
      payload_direct_class_load.metasploit_module = nil

      expect(payload_direct_class_load).not_to be_valid
      expect(payload_direct_class_load.errors[:metasploit_module]).to include(error)
    end

    it 'validates presence of payload_direct_class' do
      payload_direct_class_load.payload_direct_class = nil

      expect(payload_direct_class_load).not_to be_valid
      expect(payload_direct_class_load.errors[:payload_direct_class]).to include(error)
    end

    context 'on #metasploit_class' do
      context 'presence' do
        #
        # Callbacks
        #

        before(:each) do
          allow(payload_direct_class_load).to receive(:metasploit_class).and_return(metasploit_class)

          # for #payload_direct_class_valid
          payload_direct_class_load.valid?(validation_context)
        end

        context 'with :loading validation context' do
          let(:validation_context) {
            :loading
          }

          context 'with nil' do
            let(:metasploit_class) {
              nil
            }

            it 'adds error on :metasploit_class' do
              expect(payload_direct_class_load.errors[:metasploit_class]).not_to include(error)
            end
          end

          context 'without nil' do
            let(:metasploit_class) {
              Class.new
            }

            it 'does not add error on :metasploit_class' do
              expect(payload_direct_class_load.errors[:metasploit_class]).not_to include(error)
            end
          end
        end

        context 'without validation context' do
          let(:validation_context) {
            nil
          }

          context 'with nil' do
            let(:metasploit_class) {
              nil
            }

            it 'adds error on :metasploit_class' do
              expect(payload_direct_class_load.errors[:metasploit_class]).to include(error)
            end
          end

          context 'without nil' do
            let(:metasploit_class) {
              Class.new do
                def self.is_usable
                  true
                end
              end
            }

            it 'does not add error on :metasploit_class' do
              expect(payload_direct_class_load.errors[:metasploit_class]).not_to include(error)
            end
          end
        end
      end
    end
  end

  context '#loading_context?' do
    subject(:loading_context?) do
      payload_direct_class_load.send(:loading_context?)
    end

    context 'with :loading validation_context' do
      it 'should be true' do
        expect(payload_direct_class_load).to receive(:run_validations!) do
          expect(loading_context?).to eq(true)
        end

        payload_direct_class_load.valid?(:loading)
      end
    end

    context 'without validation_context' do
      it 'should be false' do
        expect(payload_direct_class_load).to receive(:run_validations!) do
          expect(loading_context?).to eq(false)
        end

        payload_direct_class_load.valid?
      end
    end
  end

  context '#metasploit_class' do
    subject(:metasploit_class) {
      payload_direct_class_load.metasploit_class
    }

    context 'with #logger' do
      context 'with #payload_direct_class' do
        context 'with #metasploit_module' do
          it 'does not set metasploit_module.ephemeral_cache_by_source[:class]' do
            expect {
              metasploit_class
            }.not_to change { metasploit_module.ephemeral_cache_by_source[:class] }.from(nil)
          end

          it 'sets metasploit_class.ephemeral_cache_by_source[:class]' do
            class_ephemeral_cache = metasploit_class.ephemeral_cache_by_source[:class]

            expect(class_ephemeral_cache).to be_a Metasploit::Cache::Direct::Class::Ephemeral
            expect(class_ephemeral_cache.metasploit_class).to eq(metasploit_class)
            expect(class_ephemeral_cache.metasploit_class).not_to eq(metasploit_module)
          end

          context 'with persisted' do
            it 'is not #metasploit_module' do
              expect(metasploit_class).not_to eq(metasploit_module)
            end

            specify {
              expect {
                metasploit_class
              }.to change(Metasploit::Cache::Payload::Direct::Class, :count).by(1)
            }
          end

          context 'without persisted' do
            before(:each) do
              expect(payload_direct_class).to receive(:persisted?).and_return(false)
            end

            it { is_expected.to be_nil }
          end
        end

        context 'without #metasploit_module' do
          let(:metasploit_module) {
            nil
          }

          it { is_expected.to be_nil }
        end
      end

      context 'without #payload_direct_class' do
        let(:payload_direct_class) {
          nil
        }

        context 'with #metasploit_module' do
          it { is_expected.to be_nil }
        end

        context 'without #metasploit_module' do
          let(:metasploit_module) {
            nil
          }

          it { is_expected.to be_nil }
        end
      end
    end

    context 'without #logger' do
      let(:logger) {
        nil
      }

      context 'with #payload_direct_class' do
        context 'with #metasploit_module' do
          it { is_expected.to be_nil }
        end

        context 'without #metasploit_module' do
          let(:metasploit_module) {
            nil
          }

          it { is_expected.to be_nil }
        end
      end

      context 'without #payload_direct_class' do
        let(:payload_direct_class) {
          nil
        }

        context 'with #metasploit_module' do
          it { is_expected.to be_nil }
        end

        context 'without #metasploit_module' do
          let(:metasploit_module) {
            nil
          }

          it { is_expected.to be_nil }
        end
      end
    end
  end

  context '#metasploit_class_usable' do
    subject(:metasploit_class_usable) do
      payload_direct_class_load.send(:metasploit_class_usable)
    end

    let(:error) do
      I18n.translate('metasploit.model.errors.models.metasploit/cache/direct/class/load.attributes.metasploit_class.unusable')
    end

    before(:each) do
      allow(payload_direct_class_load).to receive(:metasploit_class).and_return(metasploit_class)
    end

    context 'with #metasploit_class' do
      let(:metasploit_class) do
        double(
            'Metasploit Class',
            is_usable: is_usable
        )
      end

      context 'with is_usable' do
        let(:is_usable) {
          true
        }

        it 'should not add error on :metasploit_class' do
          metasploit_class_usable

          expect(payload_direct_class_load.errors[:metasploit_class]).not_to include(error)
        end
      end

      context 'without is_usable' do
        let(:is_usable) {
          false
        }

        it 'should not add error on :metasploit_class' do
          metasploit_class_usable

          expect(payload_direct_class_load.errors[:metasploit_class]).to include(error)
        end
      end
    end

    context 'without #metasploit_class' do
      let(:metasploit_class) do
        nil
      end

      it 'should not add error on :metasploit_class' do
        metasploit_class_usable

        expect(payload_direct_class_load.errors[:metasploit_class]).not_to include(error)
      end
    end
  end

  context '#valid?' do
    subject(:valid?) {
      payload_direct_class_load.valid?
    }

    it 'causes #metasploit_class to be defined' do
      expect {
        valid?
      }.to change { payload_direct_class_load.instance_variable_defined? :@metasploit_class }.to(true)
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

          shared_examples_for 'relative_path_prefix' do |payload_direct_class_build:, module_path_association:, relative_path_prefix:|
            context relative_path_prefix do
                            real_prefix_pathname = module_path_real_pathname.join(relative_path_prefix)

              rule = File::Find.new(
                  ftype: 'file',
                  pattern: "*#{Metasploit::Cache::Module::Ancestor::EXTENSION}",
                  path: real_prefix_pathname.to_path
              )

              rule.find do |real_path|
                real_pathname = Pathname.new(real_path)
                display_pathname = real_pathname.relative_path_from(real_prefix_pathname)
                relative_pathname = real_pathname.relative_path_from(module_path_real_pathname)

                context display_pathname.to_s do
                  let(:payload_direct_class) {
                    module_ancestor.send(payload_direct_class_build)
                  }

                  let(:metasploit_module) {
                    module_ancestor_load.metasploit_module
                  }

                  let(:module_ancestor) {
                    module_path.send(
                        module_path_association
                    ).build(
                        relative_path: relative_pathname.to_path
                    )
                  }

                  let(:module_ancestor_load) {
                    Metasploit::Cache::Module::Ancestor::Load.new(
                        # This should match the major version number of metasploit-framework
                        maximum_version: 4,
                        module_ancestor: module_ancestor,
                        logger: logger
                    )
                  }

                  it 'loads Metasploit Class' do
                    expect(module_ancestor_load).to load_metasploit_module

                    expect(payload_direct_class_load).to be_valid
                    expect(payload_direct_class).to be_persisted
                  end
                end
              end
            end
          end

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

          it_should_behave_like 'relative_path_prefix',
                                payload_direct_class_build: :build_single_payload_class,
                                module_path_association: :single_payload_ancestors,
                                relative_path_prefix: 'payloads/singles'
        end
      end
    end
  end
  # :nocov:
end