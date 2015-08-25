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

      let(:metasploit_framework) {
        double('Metasploit::Framework')
      }

      let(:module_instance) {
        FactoryGirl.build(:metasploit_cache_auxiliary_instance)
      }

      let(:module_instance_load) {
        described_class.new(
            ephemeral_class: ephemeral_class,
            logger: logger,
            metasploit_framework: metasploit_framework,
            metasploit_module_class: metasploit_module_class,
            module_instance: module_instance
        )
      }

      let(:metasploit_module_class) {
        Class.new do
          #
          # Class Attributes
          #

          class << self
            attr_accessor :framework
          end
        end.tap { |klass|
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
      Class.new do
        class << self
          attr_accessor :framework
        end
      end
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

      let(:metasploit_framework) {
        double('Metasploit::Framework')
      }

      let(:module_instance_load) {
        described_class.new(
            ephemeral_class: ephemeral_class,
            logger: logger,
            metasploit_framework: metasploit_framework,
            metasploit_module_class: metasploit_module_class,
            module_instance: module_instance
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
                logger: logger,
                metasploit_framework: metasploit_framework,
                metasploit_module_class: direct_class_load.metasploit_class,
                module_instance: module_instance
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
              # Class Attributes
              #

              class << self
                attr_accessor :framework
              end

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

          it { is_expected.to be_nil }
        end
      end

      context 'without Metasploit Module intance' do
        let(:module_instance) {
          Metasploit::Cache::Auxiliary::Instance.new
        }

        let(:metasploit_module_class) {
          Class.new do
            #
            # Class Attributes
            #

            class << self
              attr_accessor :framework
            end

            #
            # initialize
            #

            def initialize
              raise Exception
            end
          end
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

                let(:maximum_version) {
                  4
                }

                let(:metasploit_framework) {
                  double('Metasploit Framework')
                }

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
                          payload_superclass: Msf::Payload
                      )
                    }

                    let(:payload_staged_instance) {
                      payload_staged_class.build_payload_staged_instance
                    }

                    let(:payload_staged_instance_load) {
                      described_class.new(
                          ephemeral_class: Metasploit::Cache::Payload::Staged::Instance::Ephemeral,
                          logger: logger,
                          metasploit_framework: metasploit_framework,
                          metasploit_module_class: payload_staged_class_load.metasploit_class,
                          module_instance: payload_staged_instance
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
                        expect(payload_staged_class_load).to be_valid(:loading)
                        expect(payload_staged_class_load).to be_valid

                        expect(payload_staged_instance_load).to be_valid(:loading)

                        unless payload_staged_instance_load.valid?
                          # Only covered on failure
                          fail "Log:\n" \
                               "#{log_string_io.string}\n" \
                               "Expected #{payload_staged_instance_load.class} to be valid, but got errors:\n" \
                               "#{payload_staged_instance_load.errors.full_messages.join("\n")}"
                        end
                      else
                        expect(payload_staged_class_load).not_to be_valid(:loading)
                      end
                    end
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

          it_should_behave_like 'Metasploit::Cache::*::Instance::Load from relative_path_prefix',
                                module_path_real_pathname,
                                'auxiliary' do
            let(:direct_class) {
              module_ancestor.build_auxiliary_class
            }

            let(:direct_class_load) {
              Metasploit::Cache::Direct::Class::Load.new(
                  direct_class: direct_class,
                  logger: logger,
                  metasploit_module: module_ancestor_load.metasploit_module
              )
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
                  logger: logger,
                  metasploit_framework: metasploit_framework,
                  metasploit_module_class: direct_class_load.metasploit_class,
                  module_instance: module_instance
              )
            }
          end

          it_should_behave_like 'Metasploit::Cache::*::Instance::Load from relative_path_prefix',
                                module_path_real_pathname,
                                'encoders' do
            let(:direct_class) {
              module_ancestor.build_encoder_class
            }

            let(:direct_class_load) {
              Metasploit::Cache::Direct::Class::Load.new(
                  direct_class: direct_class,
                  logger: logger,
                  metasploit_module: module_ancestor_load.metasploit_module
              )
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
                  logger: logger,
                  metasploit_framework: metasploit_framework,
                  metasploit_module_class: direct_class_load.metasploit_class,
                  module_instance: module_instance
              )
            }
          end

          it_should_behave_like 'Metasploit::Cache::*::Instance::Load from relative_path_prefix',
                                module_path_real_pathname,
                                'exploits',
                                pending_reason_by_display_path: {
                                    'firefox/local/exec_shellcode.rb' => 'Missing references',
                                    'linux/http/pandora_fms_exec.rb' => 'Missing references',
                                    'linux/local/desktop_privilege_escalation.rb' => 'Missing references',
                                    'linux/local/zpanel_zsudo.rb' => 'Missing references',
                                    'multi/fileformat/js_unpacker_eval_injection.rb' => 'Missing references',
                                    'multi/handler.rb' => 'Missing DisclosureDate and missing references',
                                    'multi/misc/java_rmi_server.rb' => 'MSF authority abbreviation is not recognized',
                                    'osx/browser/safari_user_assisted_download_launch.rb' => 'Missing references',
                                    'osx/local/persistence.rb' => 'Missing references',
                                    'unix/local/setuid_nmap.rb' => 'Missing references',
                                    'unix/webapp/generic_exec.rb' => 'Missing references',
                                    'unix/webapp/openemr_upload_exec.rb' => 'EBD authority abbreviation is a typo for EDB',
                                    'unix/webapp/php_eval.rb' => 'Missing references',
                                    'unix/webapp/php_include.rb' => 'Missing references',
                                    'unix/webapp/wp_admin_shell_upload.rb' => 'Missing references',
                                    'windows/browser/malwarebytes_update_exec.rb' => "Authority abbreviation (' OSVDB') has space in it",
                                    'windows/http/xampp_webdav_upload_php.rb' => 'Missing references',
                                    'windows/local/bypassuac_injection.rb' => 'References are formatted incorrectly with an extra Array layer',
                                    'windows/local/ntapphelpcachecontrol.rb' => 'OSVEB authority abbreviation is a typo for OSVDB',
                                    'windows/local/payload_inject.rb' => 'Missing references',
                                    'windows/local/persistence.rb' => 'Missing references',
                                    'windows/local/powershell_cmd_upgrade.rb' => 'Missing references',
                                    'windows/local/pxeexploit.rb' => 'Missing references',
                                    'windows/local/service_permissions.rb' => 'Missing references'
                                } do
            let(:direct_class) {
              module_ancestor.build_exploit_class
            }

            let(:direct_class_load) {
              Metasploit::Cache::Direct::Class::Load.new(
                  direct_class: direct_class,
                  logger: logger,
                  metasploit_module: module_ancestor_load.metasploit_module
              )
            }

            let(:module_ancestors) {
              module_path.exploit_ancestors
            }

            let(:module_instance) {
              direct_class.build_exploit_instance
            }

            let(:module_instance_load) {
              described_class.new(
                  ephemeral_class: Metasploit::Cache::Exploit::Instance::Ephemeral,
                  logger: logger,
                  metasploit_framework: metasploit_framework,
                  metasploit_module_class: direct_class_load.metasploit_class,
                  module_instance: module_instance,
              )
            }
          end
          
          it_should_behave_like 'Metasploit::Cache::*::Instance::Load from relative_path_prefix',
                                module_path_real_pathname,
                                'nops' do
            let(:direct_class) {
              module_ancestor.build_nop_class
            }

            let(:direct_class_load) {
              Metasploit::Cache::Direct::Class::Load.new(
                  direct_class: direct_class,
                  logger: logger,
                  metasploit_module: module_ancestor_load.metasploit_module
              )
            }

            let(:module_ancestors) {
              module_path.nop_ancestors
            }

            let(:module_instance) {
              direct_class.build_nop_instance
            }

            let(:module_instance_load) {
              described_class.new(
                  ephemeral_class: Metasploit::Cache::Nop::Instance::Ephemeral,
                  logger: logger,
                  metasploit_framework: metasploit_framework,
                  metasploit_module_class: direct_class_load.metasploit_class,
                  module_instance: module_instance
              )
            }
          end

          it_should_behave_like 'Metasploit::Cache::*::Instance::Load from relative_path_prefix',
                                module_path_real_pathname,
                                'payloads/singles' do
            let(:direct_class) {
              module_ancestor.build_single_payload_class
            }

            let(:module_ancestors) {
              module_path.single_payload_ancestors
            }

            let(:module_instance) {
              direct_class.build_payload_single_instance
            }

            let(:module_instance_load) {
              described_class.new(
                  ephemeral_class: Metasploit::Cache::Payload::Single::Instance::Ephemeral,
                  logger: logger,
                  metasploit_framework: metasploit_framework,
                  metasploit_module_class: direct_class_load.metasploit_class,
                  module_instance: module_instance
              )
            }

            let(:direct_class_load) {
              Metasploit::Cache::Payload::Direct::Class::Load.new(
                  logger: logger,
                  metasploit_module: module_ancestor_load.metasploit_module,
                  payload_direct_class: direct_class,
                  payload_superclass: Msf::Payload
              )
            }
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


          # @note payloads/stages instances are loaded as part of
          #   spec/lib/metasploit/cache/payload/staged/class/load_spec.rb

          # @note payloads/stagers instances are loaded as part of
          #   spec/lib/metasploit/cache/payload/staged/class/load_spec.rb

          it_should_behave_like 'Metasploit::Cache::*::Instance::Load from relative_path_prefix',
                                module_path_real_pathname,
                                'post',
                                pending_reason_by_display_path: {
                                    'firefox/gather/cookies.rb' => 'Missing platforms',
                                    'firefox/gather/history.rb' => 'Missing platforms',
                                    'firefox/gather/passwords.rb' => 'Missing platforms',
                                    'firefox/manage/webcam_chat.rb' => 'Missing platforms',
                                    'windows/gather/credentials/spark_im.rb' => 'Missing platforms',
                                    'windows/gather/netlm_downgrade.rb' => 'Missing platforms',
                                } do
            let(:direct_class) {
              module_ancestor.build_post_class
            }

            let(:direct_class_load) {
              Metasploit::Cache::Direct::Class::Load.new(
                  direct_class: direct_class,
                  logger: logger,
                  metasploit_module: module_ancestor_load.metasploit_module
              )
            }

            let(:module_ancestors) {
              module_path.post_ancestors
            }

            let(:module_instance) {
              direct_class.build_post_instance
            }

            let(:module_instance_load) {
              described_class.new(
                  ephemeral_class: Metasploit::Cache::Post::Instance::Ephemeral,
                  logger: logger,
                  metasploit_framework: metasploit_framework,
                  metasploit_module_class: direct_class_load.metasploit_class,
                  module_instance: module_instance
              )
            }
          end
        end
      end
    end
  end
  # :nocov:
end