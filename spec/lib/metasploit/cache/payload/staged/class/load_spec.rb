RSpec.describe Metasploit::Cache::Payload::Staged::Class::Load, type: :model do
  include_context 'Metasploit::Cache::Spec::Unload.unload'

  context 'validations' do
    let(:error) {
      I18n.translate!('errors.messages.blank')
    }

    let(:payload_staged_class_load) {
      described_class.new
    }

    it 'validates presence of handler_module' do
      payload_staged_class_load.handler_module = nil

      expect(payload_staged_class_load).not_to be_valid
      expect(payload_staged_class_load.errors[:handler_module]).to include(error)
    end

    it 'validates presence of logger' do
      payload_staged_class_load.logger = nil

      expect(payload_staged_class_load).not_to be_valid
      expect(payload_staged_class_load.errors[:logger]).to include(error)
    end
    
    it 'validates presence of payload_stage_metasploit_module' do
      payload_staged_class_load.payload_stage_metasploit_module = nil

      expect(payload_staged_class_load).not_to be_valid
      expect(payload_staged_class_load.errors[:payload_stage_metasploit_module]).to include(error)
    end

    it 'validates presence of payload_staged_class' do
      payload_staged_class_load.payload_staged_class = nil

      expect(payload_staged_class_load).not_to be_valid
      expect(payload_staged_class_load.errors[:payload_staged_class]).to include(error)
    end
    
    it 'validates presence of payload_stager_metasploit_module' do
      payload_staged_class_load.payload_stager_metasploit_module = nil

      expect(payload_staged_class_load).not_to be_valid
      expect(payload_staged_class_load.errors[:payload_stager_metasploit_module]).to include(error)
    end
    
    it 'validates presence of payload_superclass' do
      payload_staged_class_load.payload_superclass = nil

      expect(payload_staged_class_load).not_to be_valid
      expect(payload_staged_class_load.errors[:payload_superclass]).to include(error)
    end

    context 'on #metasploit_class' do
      context 'presence' do
        #
        # Callbacks
        #

        before(:each) do
          allow(payload_staged_class_load).to receive(:metasploit_class).and_return(metasploit_class)

          # for #payload_staged_class_valid
          payload_staged_class_load.valid?(validation_context)
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
              expect(payload_staged_class_load.errors[:metasploit_class]).not_to include(error)
            end
          end

          context 'without nil' do
            let(:metasploit_class) {
              Class.new
            }

            it 'does not add error on :metasploit_class' do
              expect(payload_staged_class_load.errors[:metasploit_class]).not_to include(error)
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
              expect(payload_staged_class_load.errors[:metasploit_class]).to include(error)
            end
          end

          context 'without nil' do
            let(:metasploit_class) {
              Class.new
            }

            it 'does not add error on :metasploit_class' do
              expect(payload_staged_class_load.errors[:metasploit_class]).not_to include(error)
            end
          end
        end
      end
    end

    context 'on #payload_staged_class' do
      context 'validity' do
        let(:error) {
          I18n.translate('errors.messages.invalid')
        }

        context 'with #payload_staged_class' do
          #
          # lets
          #

          let(:payload_staged_class_load) {
            described_class.new(
                payload_staged_class: payload_staged_class
            )
          }

          let(:payload_stager_instance_handler_load_pathname) {
            Metasploit::Model::Spec.temporary_pathname.join('lib')
          }

          #
          # Callbacks
          #

          around(:each) do |example|
            load_path_before = $LOAD_PATH.dup

            begin
              example.run
            ensure
              $LOAD_PATH.replace(load_path_before)
            end
          end

          before(:each) do
            payload_stager_instance_handler_load_pathname.mkpath

            $LOAD_PATH.unshift payload_stager_instance_handler_load_pathname.to_path

            payload_staged_class.valid?
          end

          context 'with valid' do
            let(:payload_staged_class) {
              FactoryGirl.build(
                  :metasploit_cache_payload_staged_class,
                  payload_stager_instance_handler_load_pathname: payload_stager_instance_handler_load_pathname
              )
            }

            it 'does not add error on :payload_staged_class' do
              expect(payload_staged_class_load.errors[:payload_staged_class]).not_to include(error)
            end
          end

          context 'without valid due to incompatible architectures and platforms' do
            let(:payload_staged_class) {
              Metasploit::Cache::Payload::Staged::Class.new(
                  payload_stage_instance: FactoryGirl.create(
                      :metasploit_cache_payload_stage_instance,
                      :metasploit_cache_contributable_contributions,
                      :metasploit_cache_licensable_licensable_licenses,
                      # Must be after all association building traits so assocations are populated for writing contents
                      :metasploit_cache_payload_stage_instance_payload_stage_class_ancestor_contents,
                      architecturable_architectures: [
                          Metasploit::Cache::Architecturable::Architecture.new(
                              architecture: Metasploit::Cache::Architecture.where(
                                  abbreviation: 'armbe'
                              ).first!
                          )
                      ],
                      platformable_platforms: [
                          Metasploit::Cache::Platformable::Platform.new(
                              platform: Metasploit::Cache::Platform.where(
                                  fully_qualified_name: 'Android'
                              ).first!
                          )
                      ]
                  ),
                  payload_stager_instance: FactoryGirl.create(
                      :metasploit_cache_payload_stager_instance,
                      :metasploit_cache_contributable_contributions,
                      :metasploit_cache_licensable_licensable_licenses,
                      :metasploit_cache_payload_handable_handler,
                      # Must be after all association building traits so assocations are populated for writing contents
                      :metasploit_cache_payload_stager_instance_payload_stager_class_ancestor_contents,
                      architecturable_architectures: [
                          Metasploit::Cache::Architecturable::Architecture.new(
                              architecture: Metasploit::Cache::Architecture.where(
                                  abbreviation: 'cbea'
                              ).first!
                          )
                      ],
                      handler_load_pathname: payload_stager_instance_handler_load_pathname,
                      platformable_platforms: [
                          Metasploit::Cache::Platformable::Platform.new(
                              platform: Metasploit::Cache::Platform.where(
                                  fully_qualified_name: 'Linux'
                              ).first!
                          )
                      ]
                  )
              )
            }

            before(:each) do
              payload_staged_class_load.valid?
            end

            it 'adds error on :payload_staged_class' do
              expect(payload_staged_class_load.errors[:payload_staged_class]).to include(error)
            end
          end
        end

        context 'without #payload_staged_class' do
          let(:payload_staged_class_load) {
            described_class.new
          }

          before(:each) do
            payload_staged_class_load.valid?
          end

          it 'does not add error on :payload_staged_class' do
            expect(payload_staged_class_load.errors[:payload_staged_class]).not_to include(error)
          end
        end
      end
    end
  end

  context '.include_ancestor' do
    subject(:include_ancestor) {
      described_class.include_ancestor(base, source, ancestor)
    }

    let(:ancestor) {
      Module.new
    }

    let(:base) {
      Class.new do
        extend Metasploit::Cache::Ancestry
      end
    }

    let(:source) {
      :source
    }

    it 'includes ancestor' do
      expect {
        include_ancestor
      }.to change {
             base.ancestors.include? ancestor
           }.to(true)
    end

    it 'sets ancestor_by_source[source] to ancestor' do
      expect {
        include_ancestor
      }.to change {
             base.ancestor_by_source[source]
           }.to ancestor
    end
  end

  context '.metasploit_class_names' do
    subject(:metasploit_class_names) {
      described_class.metasploit_class_names(payload_staged_class)
    }

    let(:payload_stage_instance) {
      FactoryGirl.build(:metasploit_cache_payload_stage_instance)
    }

    let(:payload_stager_instance) {
      FactoryGirl.build(:metasploit_cache_payload_stager_instance)
    }

    let(:payload_staged_class) {
      Metasploit::Cache::Payload::Staged::Class.new(
          payload_stage_instance: payload_stage_instance,
          payload_stager_instance: payload_stager_instance
      )
    }

    it "starts with ['Msf', 'Payloads']" do
      expect(metasploit_class_names[0,2]).to eq(['Msf', 'Payloads'])
    end

    it 'includes stage and stager SHA1' do
      expect(metasploit_class_names).to include(
                                            'RealPathSha1HexDigest' \
                                            "#{payload_stage_instance.payload_stage_class.ancestor.real_path_sha1_hex_digest}" \
                                            'StagedBy' \
                                            'RealPathSha1HexDigest' \
                                            "#{payload_stager_instance.payload_stager_class.ancestor.real_path_sha1_hex_digest}"
                                        )
    end
  end

  context '.name_metasploit_class' do
    include_context 'Metasploit::Cache::Spec::Unload.unload'

    subject(:name_metasploit_class!) {
      described_class.name_metasploit_class!(
                         metasploit_class: metasploit_class,
                         payload_staged_class: payload_staged_class
      )
    }

    let(:metasploit_class) {
      Class.new
    }

    let(:payload_stage_instance) {
      FactoryGirl.build(:metasploit_cache_payload_stage_instance)
    }

    let(:payload_stager_instance) {
      FactoryGirl.build(:metasploit_cache_payload_stager_instance)
    }

    let(:payload_staged_class) {
      Metasploit::Cache::Payload::Staged::Class.new(
          payload_stage_instance: payload_stage_instance,
          payload_stager_instance: payload_stager_instance
      )
    }

    context 'with pre-existing' do
      before(:each) do
        stub_const('Msf::Payloads', Module.new)
      end

      it 'defines constant to metasploit_class' do
        expect {
          name_metasploit_class!
        }.to change(metasploit_class, :name).to(
                 'Msf::Payloads::' \
                 'RealPathSha1HexDigest' \
                 "#{payload_stage_instance.payload_stage_class.ancestor.real_path_sha1_hex_digest}" \
                 'StagedBy' \
                 'RealPathSha1HexDigest' \
                 "#{payload_stager_instance.payload_stager_class.ancestor.real_path_sha1_hex_digest}")
      end
    end

    context 'without pre-existing' do
      before(:each) do
        hide_const('Msf::Payloads')
      end

      it 'defines constant to metasploit_class' do
        expect {
          name_metasploit_class!
        }.to change(metasploit_class, :name).to(
                 'Msf::Payloads::' \
                 'RealPathSha1HexDigest' \
                 "#{payload_stage_instance.payload_stage_class.ancestor.real_path_sha1_hex_digest}" \
                 'StagedBy' \
                 'RealPathSha1HexDigest' \
                 "#{payload_stager_instance.payload_stager_class.ancestor.real_path_sha1_hex_digest}"
             )
      end
    end
  end

  context '#loading_context?' do
    subject(:loading_context?) do
      payload_staged_class_load.send(:loading_context?)
    end

    let(:payload_staged_class_load) {
      described_class.new
    }

    context 'with :loading validation_context' do
      it 'should be true' do
        expect(payload_staged_class_load).to receive(:run_validations!) do
          expect(loading_context?).to eq(true)
        end

        payload_staged_class_load.valid?(:loading)
      end
    end

    context 'without validation_context' do
      it 'should be false' do
        expect(payload_staged_class_load).to receive(:run_validations!) do
          expect(loading_context?).to eq(false)
        end

        payload_staged_class_load.valid?
      end
    end
  end

  context '#metasploit_class' do
    subject(:metasploit_class) {
      payload_staged_class_load.metasploit_class
    }

    let(:payload_staged_class_load) {
      described_class.new(
          handler_module: handler_module,
          logger: logger,
          payload_stage_metasploit_module: payload_stage_metasploit_module,
          payload_staged_class: payload_staged_class,
          payload_stager_metasploit_module: payload_stager_metasploit_module,
          payload_superclass: payload_superclass
      )
    }

    context 'with #handler_module' do
      let(:handler_module) {
        Module.new.tap { |handler_module|
          stub_const('HandlerModule', handler_module)
        }
      }

      context 'with #logger' do
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

        context 'with #payload_stage_metasploit_module' do
          let(:payload_stage_ancestor_load) {
            Metasploit::Cache::Module::Ancestor::Load.new(
                logger: logger,
                # This should match the major version number of metasploit-framework
                maximum_version: 4,
                module_ancestor: payload_staged_class.payload_stage_instance.payload_stage_class.ancestor
            )
          }

          let(:payload_stage_metasploit_module) {
            payload_stage_ancestor_load.metasploit_module
          }

          context 'with #payload_staged_class' do
            #
            # lets
            #

            let(:payload_staged_class) {
              FactoryGirl.build(
                  :metasploit_cache_payload_staged_class,
                  payload_stager_instance_handler_load_pathname: payload_stager_instance_handler_load_pathname
              )
            }

            let(:payload_stager_instance_handler_load_pathname) {
              Metasploit::Model::Spec.temporary_pathname.join('lib')
            }

            #
            # Callbacks
            #

            around(:each) do |example|
              load_path_before = $LOAD_PATH.dup

              begin
                example.run
              ensure
                $LOAD_PATH.replace(load_path_before)
              end
            end

            before(:each) do
              payload_stager_instance_handler_load_pathname.mkpath

              $LOAD_PATH.unshift payload_stager_instance_handler_load_pathname.to_path
            end

            context 'with #payload_stager_metasploit_module' do
              let(:payload_stager_ancestor_load) {
                Metasploit::Cache::Module::Ancestor::Load.new(
                    logger: logger,
                    # This should match the major version number of metasploit-framework
                    maximum_version: 4,
                    module_ancestor: payload_staged_class.payload_stager_instance.payload_stager_class.ancestor
                )
              }

              let(:payload_stager_metasploit_module) {
                payload_stager_ancestor_load.metasploit_module
              }

              context 'with #payload_superclass' do
                let(:payload_superclass) {
                  Metasploit::Cache::Direct::Class::Superclass
                }
                
                it 'includes handler_module in metasploit_class' do
                  expect(metasploit_class.ancestors).to include(handler_module)
                end
                
                it 'sets metasploit_class.ancestor_by_source[:handler] to handler_module' do
                  expect(metasploit_class.ancestor_by_source[:handler]).to eq(handler_module)
                end 
                
                it 'includes payload_stager_metasploit_module in metasploit_class' do
                  expect(metasploit_class.ancestors).to include(payload_stager_metasploit_module)
                end
                
                it 'sets metasploit_class.ancestor_by_source[:stager]to payload_stage_metasploit_module' do
                  expect(metasploit_class.ancestor_by_source[:stager]).to eq(payload_stager_metasploit_module)
                end
                
                it 'includes payload_stage_metasploit_module in metasploit_class' do
                  expect(metasploit_class.ancestors).to include(payload_stage_metasploit_module)
                end
                
                it 'sets metasploit_class.ancestor_by_source[:stage]to payload_stage_metasploit_module' do
                  expect(metasploit_class.ancestor_by_source[:stage]).to eq(payload_stage_metasploit_module)
                end

                it 'defers to stage, then stager, then handler' do
                  ancestors = metasploit_class.ancestors
                  stage_index = ancestors.index(payload_stage_metasploit_module)
                  stager_index = ancestors.index(payload_stager_metasploit_module)
                  handler_index = ancestors.index(handler_module)

                  expect(stage_index).to be < stager_index
                  expect(stager_index).to be < handler_index
                end

                it 'sets metasploit_class.ephemeral_cache_by_source[:class]' do
                  class_ephemeral_cache = metasploit_class.ephemeral_cache_by_source[:class]

                  expect(class_ephemeral_cache).to be_a Metasploit::Cache::Payload::Staged::Class::Ephemeral
                  expect(class_ephemeral_cache.payload_staged_metasploit_module_class).to eq(metasploit_class)
                end

                context 'with persisted' do
                  specify {
                    expect {
                      metasploit_class
                    }.to change(Metasploit::Cache::Payload::Staged::Class, :count).by(1)
                  }
                end

                context 'without persisted' do
                  before(:each) do
                    allow(payload_staged_class).to receive(:persisted?).and_return(false)
                  end

                  it { is_expected.to be_nil }
                end
              end
            end
          end
        end
      end
    end
  end

  context '#valid?' do
    subject(:valid?) {
      payload_staged_class_load.valid?
    }

    #
    # lets
    #

    let(:payload_staged_class_load) {
      described_class.new(
          handler_module: Module.new,
          logger: ActiveSupport::TaggedLogging.new(
              Logger.new(StringIO.new)
          ).tap { |logger|
            logger.level = Logger::DEBUG
          },
          payload_stage_metasploit_module: Module.new,
          payload_staged_class: FactoryGirl.build(
              :metasploit_cache_payload_staged_class,
              payload_stager_instance_handler_load_pathname: payload_stager_instance_handler_load_pathname
          ),
          payload_stager_metasploit_module: Module.new,
          payload_superclass: Class.new
      )
    }

    let(:payload_stager_instance_handler_load_pathname) {
      Metasploit::Model::Spec.temporary_pathname.join('lib')
    }

    #
    # Callbacks
    #

    around(:each) do |example|
      load_path_before = $LOAD_PATH.dup

      begin
        example.run
      ensure
        $LOAD_PATH.replace(load_path_before)
      end
    end

    before(:each) do
      payload_stager_instance_handler_load_pathname.mkpath

      $LOAD_PATH.unshift payload_stager_instance_handler_load_pathname.to_path
    end

    it 'causes #metasploit_class to be defined' do
      expect {
        valid?
      }.to change { payload_staged_class_load.instance_variable_defined? :@metasploit_class }.to(true)
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

        # use relative pathname so that context name is not dependent on build stagedory
        context module_path_relative_pathname.to_s do
          #
          # Shared examples
          #

          shared_examples_for 'loads only these stage and stager combinations' do |stager_names_by_stage_name|
            #
            # Context Methods
            #

            # Set of expected stage or stager names
            #
            # @param source_pathname [Pathname] Pathname to stages or stagers payload modules
            # @return [Set<String>] Set of stage or stager names
            def self.name_set(source_pathname)
              set = Set.new

              rule = File::Find.new(
                  ftype: 'file',
                  pattern: "*#{Metasploit::Cache::Module::Ancestor::EXTENSION}",
                  path: source_pathname.to_path
              )

              rule.find do |real_path|
                real_pathname = Pathname.new(real_path)
                relative_pathname = real_pathname.relative_path_from(source_pathname)
                name = relative_pathname.to_path[0 ... -Metasploit::Cache::Module::Ancestor::EXTENSION.length]
                set.add name
              end

              set
            end

            stage_name_set = name_set(module_path_real_pathname.join('payloads/stages'))
            stager_name_set = name_set(module_path_real_pathname.join('payloads/stagers'))

            stage_name_set.sort.each do |stage_name|

              context "with stage #{stage_name.inspect}" do
                #
                # lets
                #

                payload_stage_ancestor_relative_path = "payloads/stages/#{stage_name}.rb"

                let(:payload_stage_ancestor) {
                  module_path.stage_payload_ancestors.build(
                      relative_path: payload_stage_ancestor_relative_path
                  )
                }

                let(:payload_stage_ancestor_load) {
                  Metasploit::Cache::Module::Ancestor::Load.new(
                      logger: logger,
                      maximum_version: maximum_version,
                      module_ancestor: payload_stage_ancestor
                  )
                }

                let(:payload_stage_class) {
                  payload_stage_ancestor.build_stage_payload_class
                }

                let(:payload_stage_class_load) {
                  Metasploit::Cache::Payload::Direct::Class::Load.new(
                      logger: logger,
                      metasploit_module: payload_stage_ancestor_load.metasploit_module,
                      payload_direct_class: payload_stage_class,
                      payload_superclass: Msf::Payload
                  )
                }

                let(:payload_stage_instance) {
                  payload_stage_class.build_payload_stage_instance
                }

                let(:payload_stage_instance_load) {
                  Metasploit::Cache::Module::Instance::Load.new(
                      ephemeral_class: Metasploit::Cache::Payload::Stage::Instance::Ephemeral,
                      logger: logger,
                      metasploit_framework: metasploit_framework,
                      metasploit_module_class: payload_stage_class_load.metasploit_class,
                      module_instance: payload_stage_instance
                  )
                }

                stager_names = stager_names_by_stage_name.fetch(stage_name, [])

                stager_name_set.sort.each do |stager_name|
                  context "with stager #{stager_name.inspect}" do
                    #
                    #
                    # lets
                    #
                    #

                    #
                    # Staged
                    #

                    let(:payload_staged_class) {
                      Metasploit::Cache::Payload::Staged::Class.new(
                          payload_stage_instance: payload_stage_instance,
                          payload_stager_instance: payload_stager_instance
                      )
                    }

                    let(:payload_staged_class_load) {
                      Metasploit::Cache::Payload::Staged::Class::Load.new(
                          # constantize cached name instead of using
                          # `payload_stager_instance_load.metasploit_module_instance.handler_klass` to prove handler can be
                          # loaded directly from cache without the need to load the payload_stager_instance on reboot
                          handler_module: payload_stager_instance.handler.name.constantize,
                          logger: logger,
                          payload_stage_metasploit_module: payload_stage_ancestor_load.metasploit_module,
                          payload_staged_class: payload_staged_class,
                          payload_stager_metasploit_module: payload_stager_ancestor_load.metasploit_module,
                          payload_superclass: Metasploit::Cache::Direct::Class::Superclass
                      )
                    }

                    #
                    # Stager
                    #

                    payload_stager_ancestor_relative_path = "payloads/stagers/#{stager_name}.rb"

                    let(:payload_stager_ancestor) {
                      module_path.stager_payload_ancestors.build(
                          relative_path: payload_stager_ancestor_relative_path
                      )
                    }

                    let(:payload_stager_ancestor_load) {
                      Metasploit::Cache::Module::Ancestor::Load.new(
                          logger: logger,
                          maximum_version: maximum_version,
                          module_ancestor: payload_stager_ancestor
                      )
                    }

                    let(:payload_stager_class) {
                      payload_stager_ancestor.build_stager_payload_class
                    }

                    let(:payload_stager_class_load) {
                      Metasploit::Cache::Payload::Direct::Class::Load.new(
                          logger: logger,
                          metasploit_module: payload_stager_ancestor_load.metasploit_module,
                          payload_direct_class: payload_stager_class,
                          payload_superclass: Msf::Payload
                      )
                    }

                    let(:payload_stager_instance) {
                      payload_stager_class.build_payload_stager_instance
                    }

                    let(:payload_stager_instance_load) {
                      Metasploit::Cache::Module::Instance::Load.new(
                          ephemeral_class: Metasploit::Cache::Payload::Stager::Instance::Ephemeral,
                          logger: logger,
                          metasploit_framework: metasploit_framework,
                          metasploit_module_class: payload_stager_class_load.metasploit_class,
                          module_instance: payload_stager_instance
                      )
                    }

                    loads = stager_names.include?(stager_name)

                    if loads
                      description = 'loads'
                    else
                      description = 'does not load'
                    end

                    it "#{description}" do
                      #
                      # Stage
                      #

                      expect(payload_stage_ancestor).to be_valid

                      expect(payload_stage_ancestor_load).to be_valid(:loading)
                      expect(payload_stage_ancestor_load).to be_valid

                      expect(payload_stage_class_load).to be_valid(:loading)
                      expect(payload_stage_class_load).to be_valid

                      expect(payload_stage_instance_load).to be_valid(:loading)
                      expect(payload_stage_instance_load).to be_valid

                      #
                      # Stager
                      #

                      expect(payload_stager_ancestor).to be_valid

                      expect(payload_stager_ancestor_load).to be_valid(:loading)
                      expect(payload_stager_ancestor_load).to be_valid

                      expect(payload_stager_class_load).to be_valid(:loading)
                      expect(payload_stager_class_load).to be_valid

                      expect(payload_stager_instance_load).to be_valid(:loading)
                      expect(payload_stager_instance_load).to be_valid

                      #
                      # Staged
                      #

                      if loads
                        expectation = :to
                      else
                        expectation = :not_to
                      end

                      expect(payload_staged_class_load).send(expectation, be_valid(:loading))
                      expect(payload_staged_class_load).send(expectation, be_valid)
                    end
                  end
                end
              end
            end
          end

          #
          # lets
          #

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

          let(:maximum_version) {
            # This should match the major version number of metasploit-framework
            4
          }

          let(:metasploit_framework) {
            double('Metasploit Framework')
          }

          let(:module_path) do
            FactoryGirl.create(
                :metasploit_cache_module_path,
                gem: 'metasploit-framework',
                name: 'modules',
                real_path: module_path_real_path
            )
          end

          it_should_behave_like 'loads only these stage and stager combinations',
                                {
                                    'android/meterpreter' => %w{
                                        android/reverse_http
                                        android/reverse_https
                                        android/reverse_tcp
                                    },
                                    'android/shell' => %w{
                                        android/reverse_http
                                        android/reverse_https
                                        android/reverse_tcp
                                    },
                                    'bsdi/x86/shell' => %w{
                                        bsdi/x86/bind_tcp
                                        bsdi/x86/reverse_tcp
                                    },
                                    'bsd/x86/shell' => %w{
                                        bsd/x86/bind_ipv6_tcp
                                        bsd/x86/bind_tcp
                                        bsd/x86/find_tag
                                        bsd/x86/reverse_ipv6_tcp
                                        bsd/x86/reverse_tcp
                                    },
                                    'java/meterpreter' => %w{
                                        java/bind_tcp
                                        java/reverse_http
                                        java/reverse_https
                                        java/reverse_tcp
                                    },
                                    'java/shell' => %w{
                                        java/bind_tcp
                                        java/reverse_http
                                        java/reverse_https
                                        java/reverse_tcp
                                    },
                                    'linux/armle/shell' => %w{
                                        linux/armle/bind_tcp
                                        linux/armle/reverse_tcp
                                    },
                                    'linux/mipsbe/shell' => %w{
                                        linux/mipsbe/reverse_tcp
                                    },
                                    'linux/mipsle/shell' => %w{
                                        linux/mipsle/reverse_tcp
                                    },
                                    'linux/x64/shell' => %w{
                                        linux/x64/bind_tcp
                                        linux/x64/reverse_tcp
                                    },
                                    'linux/x86/meterpreter' => %w{
                                        linux/x86/bind_ipv6_tcp
                                        linux/x86/bind_ipv6_tcp_uuid
                                        linux/x86/bind_nonx_tcp
                                        linux/x86/bind_tcp
                                        linux/x86/bind_tcp_uuid
                                        linux/x86/find_tag
                                        linux/x86/reverse_ipv6_tcp
                                        linux/x86/reverse_nonx_tcp
                                        linux/x86/reverse_tcp
                                        linux/x86/reverse_tcp_uuid
                                    },
                                    'linux/x86/shell' => %w{
                                        linux/x86/bind_ipv6_tcp
                                        linux/x86/bind_ipv6_tcp_uuid
                                        linux/x86/bind_nonx_tcp
                                        linux/x86/bind_tcp
                                        linux/x86/bind_tcp_uuid
                                        linux/x86/find_tag
                                        linux/x86/reverse_ipv6_tcp
                                        linux/x86/reverse_nonx_tcp
                                        linux/x86/reverse_tcp
                                        linux/x86/reverse_tcp_uuid
                                    },
                                    'netware/shell' => %w{
                                        netware/reverse_tcp
                                    },
                                    'osx/armle/execute' => %w{
                                        osx/armle/bind_tcp
                                        osx/armle/reverse_tcp
                                    },
                                    'osx/armle/shell' => %w{
                                        osx/armle/bind_tcp
                                        osx/armle/reverse_tcp
                                    },
                                    'osx/ppc/shell' => %w{
                                        osx/ppc/bind_tcp
                                        osx/ppc/find_tag
                                        osx/ppc/reverse_tcp
                                    },
                                    'osx/x64/dupandexecve' => %w{
                                        osx/x64/bind_tcp
                                        osx/x64/reverse_tcp
                                    },
                                    'osx/x86/bundleinject' => %w{
                                        osx/x86/bind_tcp
                                        osx/x86/reverse_tcp
                                    },
                                    'osx/x86/isight' => %w{
                                        osx/x86/bind_tcp
                                        osx/x86/reverse_tcp
                                    },
                                    'osx/x86/vforkshell' => %w{
                                        osx/x86/bind_tcp
                                        osx/x86/reverse_tcp
                                    },
                                    'php/meterpreter' => %w{
                                        php/bind_tcp
                                        php/bind_tcp_ipv6
                                        php/bind_tcp_ipv6_uuid
                                        php/bind_tcp_uuid
                                        php/reverse_tcp
                                        php/reverse_tcp_uuid
                                    },
                                    'python/meterpreter' => %w{
                                        python/bind_tcp
                                        python/bind_tcp_uuid
                                        python/reverse_http
                                        python/reverse_https
                                        python/reverse_tcp
                                        python/reverse_tcp_uuid
                                    },
                                    'windows/dllinject' => %w{
                                        windows/bind_hidden_ipknock_tcp
                                        windows/bind_hidden_tcp
                                        windows/bind_ipv6_tcp
                                        windows/bind_ipv6_tcp_uuid
                                        windows/bind_nonx_tcp
                                        windows/bind_tcp
                                        windows/bind_tcp_rc4
                                        windows/bind_tcp_uuid
                                        windows/findtag_ord
                                        windows/reverse_hop_http
                                        windows/reverse_http
                                        windows/reverse_http_proxy_pstore
                                        windows/reverse_https
                                        windows/reverse_https_proxy
                                        windows/reverse_ipv6_tcp
                                        windows/reverse_nonx_tcp
                                        windows/reverse_ord_tcp
                                        windows/reverse_tcp
                                        windows/reverse_tcp_allports
                                        windows/reverse_tcp_dns
                                        windows/reverse_tcp_rc4
                                        windows/reverse_tcp_rc4_dns
                                        windows/reverse_tcp_uuid
                                        windows/reverse_winhttp
                                        windows/reverse_winhttps
                                    },
                                    'windows/meterpreter' => %w{
                                        windows/bind_hidden_ipknock_tcp
                                        windows/bind_hidden_tcp
                                        windows/bind_ipv6_tcp
                                        windows/bind_ipv6_tcp_uuid
                                        windows/bind_nonx_tcp
                                        windows/bind_tcp
                                        windows/bind_tcp_rc4
                                        windows/bind_tcp_uuid
                                        windows/findtag_ord
                                        windows/reverse_hop_http
                                        windows/reverse_http
                                        windows/reverse_http_proxy_pstore
                                        windows/reverse_https
                                        windows/reverse_https_proxy
                                        windows/reverse_ipv6_tcp
                                        windows/reverse_nonx_tcp
                                        windows/reverse_ord_tcp
                                        windows/reverse_tcp
                                        windows/reverse_tcp_allports
                                        windows/reverse_tcp_dns
                                        windows/reverse_tcp_rc4
                                        windows/reverse_tcp_rc4_dns
                                        windows/reverse_tcp_uuid
                                        windows/reverse_winhttp
                                        windows/reverse_winhttps
                                    },
                                    'windows/patchupdllinject' => %w{
                                        windows/bind_hidden_ipknock_tcp
                                        windows/bind_hidden_tcp
                                        windows/bind_ipv6_tcp
                                        windows/bind_ipv6_tcp_uuid
                                        windows/bind_nonx_tcp
                                        windows/bind_tcp
                                        windows/bind_tcp_rc4
                                        windows/bind_tcp_uuid
                                        windows/findtag_ord
                                        windows/reverse_hop_http
                                        windows/reverse_http
                                        windows/reverse_http_proxy_pstore
                                        windows/reverse_https
                                        windows/reverse_https_proxy
                                        windows/reverse_ipv6_tcp
                                        windows/reverse_nonx_tcp
                                        windows/reverse_ord_tcp
                                        windows/reverse_tcp
                                        windows/reverse_tcp_allports
                                        windows/reverse_tcp_dns
                                        windows/reverse_tcp_rc4
                                        windows/reverse_tcp_rc4_dns
                                        windows/reverse_tcp_uuid
                                        windows/reverse_winhttp
                                        windows/reverse_winhttps
                                    },
                                    'windows/patchupmeterpreter' => %w{
                                        windows/bind_hidden_ipknock_tcp
                                        windows/bind_hidden_tcp
                                        windows/bind_ipv6_tcp
                                        windows/bind_ipv6_tcp_uuid
                                        windows/bind_nonx_tcp
                                        windows/bind_tcp
                                        windows/bind_tcp_rc4
                                        windows/bind_tcp_uuid
                                        windows/findtag_ord
                                        windows/reverse_hop_http
                                        windows/reverse_http
                                        windows/reverse_http_proxy_pstore
                                        windows/reverse_https
                                        windows/reverse_https_proxy
                                        windows/reverse_ipv6_tcp
                                        windows/reverse_nonx_tcp
                                        windows/reverse_ord_tcp
                                        windows/reverse_tcp
                                        windows/reverse_tcp_allports
                                        windows/reverse_tcp_dns
                                        windows/reverse_tcp_rc4
                                        windows/reverse_tcp_rc4_dns
                                        windows/reverse_tcp_uuid
                                        windows/reverse_winhttp
                                        windows/reverse_winhttps
                                    },
                                    'windows/shell' => %w{
                                        windows/bind_hidden_ipknock_tcp
                                        windows/bind_hidden_tcp
                                        windows/bind_ipv6_tcp
                                        windows/bind_ipv6_tcp_uuid
                                        windows/bind_nonx_tcp
                                        windows/bind_tcp
                                        windows/bind_tcp_rc4
                                        windows/bind_tcp_uuid
                                        windows/findtag_ord
                                        windows/reverse_hop_http
                                        windows/reverse_http
                                        windows/reverse_http_proxy_pstore
                                        windows/reverse_https
                                        windows/reverse_https_proxy
                                        windows/reverse_ipv6_tcp
                                        windows/reverse_nonx_tcp
                                        windows/reverse_ord_tcp
                                        windows/reverse_tcp
                                        windows/reverse_tcp_allports
                                        windows/reverse_tcp_dns
                                        windows/reverse_tcp_rc4
                                        windows/reverse_tcp_rc4_dns
                                        windows/reverse_tcp_uuid
                                        windows/reverse_winhttp
                                        windows/reverse_winhttps
                                    },
                                    'windows/upexec' => %w{
                                        windows/bind_hidden_ipknock_tcp
                                        windows/bind_hidden_tcp
                                        windows/bind_ipv6_tcp
                                        windows/bind_ipv6_tcp_uuid
                                        windows/bind_nonx_tcp
                                        windows/bind_tcp
                                        windows/bind_tcp_rc4
                                        windows/bind_tcp_uuid
                                        windows/findtag_ord
                                        windows/reverse_hop_http
                                        windows/reverse_http
                                        windows/reverse_http_proxy_pstore
                                        windows/reverse_https
                                        windows/reverse_https_proxy
                                        windows/reverse_ipv6_tcp
                                        windows/reverse_nonx_tcp
                                        windows/reverse_ord_tcp
                                        windows/reverse_tcp
                                        windows/reverse_tcp_allports
                                        windows/reverse_tcp_dns
                                        windows/reverse_tcp_rc4
                                        windows/reverse_tcp_rc4_dns
                                        windows/reverse_tcp_uuid
                                        windows/reverse_winhttp
                                        windows/reverse_winhttps
                                    },
                                    'windows/vncinject' => %w{
                                        windows/bind_hidden_ipknock_tcp
                                        windows/bind_hidden_tcp
                                        windows/bind_ipv6_tcp
                                        windows/bind_ipv6_tcp_uuid
                                        windows/bind_nonx_tcp
                                        windows/bind_tcp
                                        windows/bind_tcp_rc4
                                        windows/bind_tcp_uuid
                                        windows/findtag_ord
                                        windows/reverse_hop_http
                                        windows/reverse_http
                                        windows/reverse_http_proxy_pstore
                                        windows/reverse_https
                                        windows/reverse_https_proxy
                                        windows/reverse_ipv6_tcp
                                        windows/reverse_nonx_tcp
                                        windows/reverse_ord_tcp
                                        windows/reverse_tcp
                                        windows/reverse_tcp_allports
                                        windows/reverse_tcp_dns
                                        windows/reverse_tcp_rc4
                                        windows/reverse_tcp_rc4_dns
                                        windows/reverse_tcp_uuid
                                        windows/reverse_winhttp
                                        windows/reverse_winhttps
                                    },
                                    'windows/x64/meterpreter' => %w{
                                        windows/x64/bind_ipv6_tcp
                                        windows/x64/bind_ipv6_tcp_uuid
                                        windows/x64/bind_tcp
                                        windows/x64/bind_tcp_uuid
                                        windows/x64/reverse_http
                                        windows/x64/reverse_https
                                        windows/x64/reverse_tcp
                                        windows/x64/reverse_tcp_uuid
                                        windows/x64/reverse_winhttp
                                        windows/x64/reverse_winhttps
                                    },
                                    'windows/x64/shell' => %w{
                                        windows/x64/bind_ipv6_tcp
                                        windows/x64/bind_ipv6_tcp_uuid
                                        windows/x64/bind_tcp
                                        windows/x64/bind_tcp_uuid
                                        windows/x64/reverse_http
                                        windows/x64/reverse_https
                                        windows/x64/reverse_tcp
                                        windows/x64/reverse_tcp_uuid
                                        windows/x64/reverse_winhttp
                                        windows/x64/reverse_winhttps
                                    },
                                    'windows/x64/vncinject' => %w{
                                        windows/x64/bind_ipv6_tcp
                                        windows/x64/bind_ipv6_tcp_uuid
                                        windows/x64/bind_tcp
                                        windows/x64/bind_tcp_uuid
                                        windows/x64/reverse_http
                                        windows/x64/reverse_https
                                        windows/x64/reverse_tcp
                                        windows/x64/reverse_tcp_uuid
                                        windows/x64/reverse_winhttp
                                        windows/x64/reverse_winhttps
                                    }
                                }
        end
      end
    end
  end
  # :nocov:
end