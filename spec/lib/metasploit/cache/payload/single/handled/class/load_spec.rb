RSpec.describe Metasploit::Cache::Payload::Single::Handled::Class::Load, type: :model do
  include_context 'Metasploit::Cache::Spec::Unload.unload'

  context 'validations' do
    let(:error) {
      I18n.translate!('errors.messages.blank')
    }

    let(:payload_single_handled_class_load) {
      described_class.new
    }

    it 'validates presence of handler_module' do
      payload_single_handled_class_load.handler_module = nil

      expect(payload_single_handled_class_load).not_to be_valid
      expect(payload_single_handled_class_load.errors[:handler_module]).to include(error)
    end

    it 'validates presence of logger' do
      payload_single_handled_class_load.logger = nil

      expect(payload_single_handled_class_load).not_to be_valid
      expect(payload_single_handled_class_load.errors[:logger]).to include(error)
    end
    
    it 'validates presence of metasploit_module' do
      payload_single_handled_class_load.metasploit_module = nil

      expect(payload_single_handled_class_load).not_to be_valid
      expect(payload_single_handled_class_load.errors[:metasploit_module]).to include(error)
    end

    it 'validates presence of payload_single_handled_class' do
      payload_single_handled_class_load.payload_single_handled_class = nil

      expect(payload_single_handled_class_load).not_to be_valid
      expect(payload_single_handled_class_load.errors[:payload_single_handled_class]).to include(error)
    end

    it 'validates presence of payload_superclass' do
      payload_single_handled_class_load.payload_superclass = nil

      expect(payload_single_handled_class_load).not_to be_valid
      expect(payload_single_handled_class_load.errors[:payload_superclass]).to include(error)
    end

    context 'on #metasploit_class' do
      context 'presence' do
        #
        # Callbacks
        #

        before(:each) do
          allow(payload_single_handled_class_load).to receive(:metasploit_class).and_return(metasploit_class)

          # for #payload_single_handled_class_valid
          payload_single_handled_class_load.valid?(validation_context)
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
              expect(payload_single_handled_class_load.errors[:metasploit_class]).not_to include(error)
            end
          end

          context 'without nil' do
            let(:metasploit_class) {
              Class.new
            }

            it 'does not add error on :metasploit_class' do
              expect(payload_single_handled_class_load.errors[:metasploit_class]).not_to include(error)
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
              expect(payload_single_handled_class_load.errors[:metasploit_class]).to include(error)
            end
          end

          context 'without nil' do
            let(:metasploit_class) {
              Class.new
            }

            it 'does not add error on :metasploit_class' do
              expect(payload_single_handled_class_load.errors[:metasploit_class]).not_to include(error)
            end
          end
        end
      end
    end

    context 'on #payload_single_handled_class' do
      context 'validity' do
        let(:error) {
          I18n.translate('errors.messages.invalid')
        }

        context 'with #payload_single_handled_class' do
          include_context ':metasploit_cache_payload_handler_module'

          #
          # lets
          #

          let(:payload_single_handled_class_load) {
            described_class.new(
                payload_single_handled_class: payload_single_handled_class
            )
          }

          #
          # Callbacks
          #

          before(:each) do
            payload_single_handled_class_load.valid?
          end

          context 'with valid' do
            let(:payload_single_handled_class) {
              FactoryGirl.build(
                  :metasploit_cache_payload_single_handled_class,
                  payload_single_unhandled_instance_handler_load_pathname: metasploit_cache_payload_handler_module_load_pathname
              )
            }

            it 'does not add error on :payload_single_handled_class' do
              expect(payload_single_handled_class_load.errors[:payload_single_handled_class]).not_to include(error)
            end
          end

          context 'without valid' do
            let(:payload_single_handled_class) {
              Metasploit::Cache::Payload::Single::Handled::Class.new
            }

            it 'adds error on :payload_single_handled_class' do
              expect(payload_single_handled_class_load.errors[:payload_single_handled_class]).to include(error)
            end
          end
        end

        context 'without #payload_single_handled_class' do
          let(:payload_single_handled_class_load) {
            described_class.new
          }

          before(:each) do
            payload_single_handled_class_load.valid?
          end

          it 'does not add error on :payload_single_handled_class' do
            expect(payload_single_handled_class_load.errors[:payload_single_handled_class]).not_to include(error)
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
      described_class.metasploit_class_names(payload_single_handled_class)
    }

    let(:payload_single_handled_class) {
      Metasploit::Cache::Payload::Single::Handled::Class.new(
          payload_single_unhandled_instance: payload_single_unhandled_instance
      )
    }

    let(:payload_single_unhandled_instance) {
      FactoryGirl.build(:metasploit_cache_payload_single_unhandled_instance)
    }

    it "starts with ['Msf', 'Payloads', 'Handled']" do
      expect(metasploit_class_names[0, 3]).to eq(['Msf', 'Payloads', 'Handled'])
    end

    it 'includes single SHA1' do
      expect(metasploit_class_names).to include(
                                            'RealPathSha1HexDigest' \
                                            "#{payload_single_unhandled_instance.payload_single_unhandled_class.ancestor.real_path_sha1_hex_digest}"
                                        )
    end
  end

  context '#loading_context?' do
    subject(:loading_context?) do
      payload_single_handled_class_load.send(:loading_context?)
    end

    let(:payload_single_handled_class_load) {
      described_class.new
    }

    context 'with :loading validation_context' do
      it 'should be true' do
        expect(payload_single_handled_class_load).to receive(:run_validations!) do
          expect(loading_context?).to eq(true)
        end

        payload_single_handled_class_load.valid?(:loading)
      end
    end

    context 'without validation_context' do
      it 'should be false' do
        expect(payload_single_handled_class_load).to receive(:run_validations!) do
          expect(loading_context?).to eq(false)
        end

        payload_single_handled_class_load.valid?
      end
    end
  end

  context '#metasploit_class' do
    subject(:metasploit_class) {
      payload_single_handled_class_load.metasploit_class
    }

    let(:payload_single_handled_class_load) {
      described_class.new(
          handler_module: handler_module,
          logger: logger,
          metasploit_module: metasploit_module,
          payload_single_handled_class: payload_single_handled_class,
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
        include_context 'ActiveSupport::TaggedLogging'

        context 'with #metasploit_module' do
          let(:payload_single_ancestor_load) {
            Metasploit::Cache::Module::Ancestor::Load.new(
                logger: logger,
                # This should match the major version number of metasploit-framework
                maximum_version: 4,
                module_ancestor: payload_single_handled_class.payload_single_unhandled_instance.payload_single_unhandled_class.ancestor,
                persister_class: Metasploit::Cache::Module::Ancestor::Persister
            )
          }

          let(:metasploit_module) {
            payload_single_ancestor_load.metasploit_module
          }

          context 'with #payload_single_handled_class' do
            include_context ':metasploit_cache_payload_handler_module'

            #
            # lets
            #

            let(:payload_single_handled_class) {
              FactoryGirl.build(
                  :metasploit_cache_payload_single_handled_class,
                  payload_single_unhandled_instance_handler_load_pathname: metasploit_cache_payload_handler_module_load_pathname
              )
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

              it 'includes metasploit_module in metasploit_class' do
                expect(metasploit_class.ancestors).to include(metasploit_module)
              end

              it 'sets metasploit_class.ancestor_by_source[:single]to metasploit_module' do
                expect(metasploit_class.ancestor_by_source[:single]).to eq(metasploit_module)
              end

              it 'defers to single, then handler' do
                ancestors = metasploit_class.ancestors
                single_index = ancestors.index(metasploit_module)
                handler_index = ancestors.index(handler_module)

                expect(single_index).to be < handler_index
              end

              it 'sets metasploit_class.persister_by_source[:class]' do
                class_persister = metasploit_class.persister_by_source[:class]

                expect(class_persister).to be_a Metasploit::Cache::Payload::Single::Handled::Class::Persister
                expect(class_persister.ephemeral).to eq(metasploit_class)
              end

              context 'with persisted' do
                specify {
                  expect {
                    metasploit_class
                  }.to change(Metasploit::Cache::Payload::Single::Handled::Class, :count).by(1)
                }
              end

              context 'without persisted' do
                before(:each) do
                  allow(payload_single_handled_class).to receive(:persisted?).and_return(false)
                end

                it { is_expected.to be_nil }
              end
            end
          end
        end
      end
    end
  end

  context '#valid?' do
    include_context 'ActiveSupport::TaggedLogging'
    include_context ':metasploit_cache_payload_handler_module'

    subject(:valid?) {
      payload_single_handled_class_load.valid?
    }

    #
    # lets
    #

    let(:payload_single_handled_class_load) {
      described_class.new(
          handler_module: Module.new,
          logger: logger,
          metasploit_module: Module.new,
          payload_single_handled_class: FactoryGirl.build(
              :metasploit_cache_payload_single_handled_class,
              payload_single_unhandled_instance_handler_load_pathname: metasploit_cache_payload_handler_module_load_pathname
          ),
          payload_superclass: Class.new
      )
    }

    it 'causes #metasploit_class to be defined' do
      expect {
        valid?
      }.to change { payload_single_handled_class_load.instance_variable_defined? :@metasploit_class }.to(true)
    end
  end


  # @note testing of 'metasploit-framework/modules/payload/singles' done in
  #   spec/lib/metasploit/cache/module/instance/load_spec.rb
end