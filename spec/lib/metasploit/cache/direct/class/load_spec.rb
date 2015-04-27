RSpec.describe Metasploit::Cache::Direct::Class::Load do
  include_context 'Metasploit::Cache::Module::Ancestor::Spec::Unload.unload'

  subject(:direct_class_load) {
    described_class.new(
        direct_class: direct_class,
        logger: logger,
        metasploit_module: metasploit_module
    )
  }

  let(:direct_class) {
    FactoryGirl.build(
        :metasploit_cache_auxiliary_class,
        rank: module_rank
    ).tap { |direct_class|
      # Set to nil after build so that template contains a rank, but it's not yet in the record
      direct_class.rank = nil
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
    Class.new.tap { |metasploit_module|
      metasploit_module.extend Metasploit::Cache::Cacheable

      module_rank = self.module_rank

      metasploit_module.define_singleton_method(:rank) do
        module_rank.number
      end
    }
  }

  context 'validations' do
    let(:error) {
      I18n.translate!('errors.messages.blank')
    }

    it 'validates presence of direct_class' do
      direct_class_load.direct_class = nil

      expect(direct_class_load).not_to be_valid
      expect(direct_class_load.errors[:direct_class]).to include(error)
    end

    it 'validates presence of logger' do
      direct_class_load.logger = nil

      expect(direct_class_load).not_to be_valid
      expect(direct_class_load.errors[:logger]).to include(error)
    end

    it 'validates presence of metasploit_module' do
      direct_class_load.metasploit_module = nil

      expect(direct_class_load).not_to be_valid
      expect(direct_class_load.errors[:metasploit_module]).to include(error)
    end

    context 'on #metasploit_class' do
      context 'presence' do
        #
        # Callbacks
        #

        before(:each) do
          allow(direct_class_load).to receive(:metasploit_class).and_return(metasploit_class)

          # for #direct_class_valid
          direct_class_load.valid?(validation_context)
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
              expect(direct_class_load.errors[:metasploit_class]).not_to include(error)
            end
          end

          context 'without nil' do
            let(:metasploit_class) {
              Class.new
            }

            it 'does not add error on :metasploit_class' do
              expect(direct_class_load.errors[:metasploit_class]).not_to include(error)
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
              expect(direct_class_load.errors[:metasploit_class]).to include(error)
            end
          end

          context 'without nil' do
            let(:metasploit_class) {
              Class.new
            }

            it 'does not add error on :metasploit_class' do
              expect(direct_class_load.errors[:metasploit_class]).not_to include(error)
            end
          end
        end
      end
    end
  end

  context '#loading_context?' do
    subject(:loading_context?) do
      direct_class_load.send(:loading_context?)
    end

    context 'with :loading validation_context' do
      it 'should be true' do
        expect(direct_class_load).to receive(:run_validations!) do
          expect(loading_context?).to eq(true)
        end

        direct_class_load.valid?(:loading)
      end
    end

    context 'without validation_context' do
      it 'should be false' do
        expect(direct_class_load).to receive(:run_validations!) do
          expect(loading_context?).to eq(false)
        end

        direct_class_load.valid?
      end
    end
  end

  context '#metasploit_class' do
    subject(:metasploit_class) {
      direct_class_load.metasploit_class
    }

    context 'with #logger' do
      context 'with #direct_class' do
        context 'with #metasploit_module' do
          it 'sets metasploit_module.ephemeral_cache_by_source[:class]' do
            expect {
              metasploit_class
            }.to change {
                   metasploit_module.ephemeral_cache_by_source[:class]
                 }.to instance_of(Metasploit::Cache::Direct::Class::Ephemeral)
          end

          context 'with persisted' do
            it 'is #metasploit_module' do
              expect(metasploit_class).to eq(metasploit_module)
            end

            specify {
              expect {
                metasploit_class
              }.to change(Metasploit::Cache::Direct::Class, :count).by(1)
            }
          end

          context 'without persisted' do
            before(:each) do
              expect(direct_class).to receive(:persisted?).and_return(false)
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

      context 'without #direct_class' do
        let(:direct_class) {
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

      context 'with #direct_class' do
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

      context 'without #direct_class' do
        let(:direct_class) {
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

  context '#valid?' do
    subject(:valid?) {
      direct_class_load.valid?
    }

    it 'causes #metasploit_class to be defined' do
      expect {
        valid?
      }.to change { direct_class_load.instance_variable_defined? :@metasploit_class }.to(true)
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

          shared_examples_for 'relative_path_prefix' do |direct_class_build:, module_path_association:, relative_path_prefix:|
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
                  let(:direct_class) {
                    module_ancestor.send(direct_class_build)
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

                    expect(direct_class_load).to be_valid
                    expect(direct_class).to be_persisted
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
                                direct_class_build: :build_auxiliary_class,
                                module_path_association: :auxiliary_ancestors,
                                relative_path_prefix: 'auxiliary'

          it_should_behave_like 'relative_path_prefix',
                                direct_class_build: :build_nop_class,
                                module_path_association: :nop_ancestors,
                                relative_path_prefix: 'nops'

          it_should_behave_like 'relative_path_prefix',
                                direct_class_build: :build_encoder_class,
                                module_path_association: :encoder_ancestors,
                                relative_path_prefix: 'encoders'

          it_should_behave_like 'relative_path_prefix',
                                direct_class_build: :build_exploit_class,
                                module_path_association: :exploit_ancestors,
                                relative_path_prefix: 'exploits'

          it_should_behave_like 'relative_path_prefix',
                                direct_class_build: :build_post_class,
                                module_path_association: :post_ancestors,
                                relative_path_prefix: 'post'
        end
      end
    end
  end
  # :nocov:
end