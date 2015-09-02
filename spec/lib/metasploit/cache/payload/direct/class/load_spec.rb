RSpec.describe Metasploit::Cache::Payload::Unhandled::Class::Load do
  include_context 'ActiveSupport::TaggedLogging'
  include_context 'Metasploit::Cache::Spec::Unload.unload'

  subject(:payload_unhandled_class_load) {
    described_class.new(
        logger: logger,
        metasploit_module: metasploit_module,
        payload_unhandled_class: payload_unhandled_class,
        payload_superclass: Metasploit::Cache::Direct::Class::Superclass
    )
  }

  let(:payload_unhandled_class) {
    FactoryGirl.build(
        :metasploit_cache_payload_single_unhandled_class,
        rank: module_rank
    ).tap { |payload_unhandled_class|
      # Set to nil after build so that template contains a rank, but it's not yet in the record
      payload_unhandled_class.rank = nil
    }
  }

  let(:module_rank) {
    FactoryGirl.generate :metasploit_cache_module_rank
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
      payload_unhandled_class_load.logger = nil

      expect(payload_unhandled_class_load).not_to be_valid
      expect(payload_unhandled_class_load.errors[:logger]).to include(error)
    end

    it 'validates presence of metasploit_module' do
      payload_unhandled_class_load.metasploit_module = nil

      expect(payload_unhandled_class_load).not_to be_valid
      expect(payload_unhandled_class_load.errors[:metasploit_module]).to include(error)
    end

    it 'validates presence of payload_unhandled_class' do
      payload_unhandled_class_load.payload_unhandled_class = nil

      expect(payload_unhandled_class_load).not_to be_valid
      expect(payload_unhandled_class_load.errors[:payload_unhandled_class]).to include(error)
    end

    context 'on #metasploit_class' do
      context 'presence' do
        #
        # Callbacks
        #

        before(:each) do
          allow(payload_unhandled_class_load).to receive(:metasploit_class).and_return(metasploit_class)

          # for #payload_unhandled_class_valid
          payload_unhandled_class_load.valid?(validation_context)
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
              expect(payload_unhandled_class_load.errors[:metasploit_class]).not_to include(error)
            end
          end

          context 'without nil' do
            let(:metasploit_class) {
              Class.new
            }

            it 'does not add error on :metasploit_class' do
              expect(payload_unhandled_class_load.errors[:metasploit_class]).not_to include(error)
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
              expect(payload_unhandled_class_load.errors[:metasploit_class]).to include(error)
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
              expect(payload_unhandled_class_load.errors[:metasploit_class]).not_to include(error)
            end
          end
        end
      end
    end
  end

  context '#loading_context?' do
    subject(:loading_context?) do
      payload_unhandled_class_load.send(:loading_context?)
    end

    context 'with :loading validation_context' do
      it 'should be true' do
        expect(payload_unhandled_class_load).to receive(:run_validations!) do
          expect(loading_context?).to eq(true)
        end

        payload_unhandled_class_load.valid?(:loading)
      end
    end

    context 'without validation_context' do
      it 'should be false' do
        expect(payload_unhandled_class_load).to receive(:run_validations!) do
          expect(loading_context?).to eq(false)
        end

        payload_unhandled_class_load.valid?
      end
    end
  end

  context '#metasploit_class' do
    subject(:metasploit_class) {
      payload_unhandled_class_load.metasploit_class
    }

    context 'with #logger' do
      context 'with #payload_unhandled_class' do
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
              }.to change(Metasploit::Cache::Payload::Unhandled::Class, :count).by(1)
            }
          end

          context 'without persisted' do
            before(:each) do
              expect(payload_unhandled_class).to receive(:persisted?).and_return(false)
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

      context 'without #payload_unhandled_class' do
        let(:payload_unhandled_class) {
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

      context 'with #payload_unhandled_class' do
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

      context 'without #payload_unhandled_class' do
        let(:payload_unhandled_class) {
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
      payload_unhandled_class_load.send(:metasploit_class_usable)
    end

    let(:error) do
      I18n.translate('metasploit.model.errors.models.metasploit/cache/direct/class/load.attributes.metasploit_class.unusable')
    end

    before(:each) do
      allow(payload_unhandled_class_load).to receive(:metasploit_class).and_return(metasploit_class)
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

          expect(payload_unhandled_class_load.errors[:metasploit_class]).not_to include(error)
        end
      end

      context 'without is_usable' do
        let(:is_usable) {
          false
        }

        it 'should not add error on :metasploit_class' do
          metasploit_class_usable

          expect(payload_unhandled_class_load.errors[:metasploit_class]).to include(error)
        end
      end
    end

    context 'without #metasploit_class' do
      let(:metasploit_class) do
        nil
      end

      it 'should not add error on :metasploit_class' do
        metasploit_class_usable

        expect(payload_unhandled_class_load.errors[:metasploit_class]).not_to include(error)
      end
    end
  end

  context '#valid?' do
    subject(:valid?) {
      payload_unhandled_class_load.valid?
    }

    it 'causes #metasploit_class to be defined' do
      expect {
        valid?
      }.to change { payload_unhandled_class_load.instance_variable_defined? :@metasploit_class }.to(true)
    end
  end

  # @see spec/lib/metasploit/cache/module/instance/load_spec.rb for payloads/singles testing
  # @see spec/lib/metasploit/cache/module/instance/load_spec.rb for payloads/stages testing
  # @see spec/lib/metasploit/cache/module/instance/load_spec.rb for payloads/stagers testing
end