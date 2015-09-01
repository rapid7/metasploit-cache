RSpec.describe Metasploit::Cache::Payload::Direct::Class::Load do
  include_context 'ActiveSupport::TaggedLogging'
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

  context '.name_metasploit_class' do
    include_context 'Metasploit::Cache::Spec::Unload.unload'

    subject(:name_metasploit_class!) {
      described_class.name_metasploit_class!(
                         metasploit_class: metasploit_class,
                         payload_direct_class: payload_direct_class
      )
    }

    let(:metasploit_class) {
      Class.new
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
                 "#{payload_direct_class.ancestor.real_path_sha1_hex_digest}"
             )
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
                 "#{payload_direct_class.ancestor.real_path_sha1_hex_digest}"
             )
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

  # @see spec/lib/metasploit/cache/module/instance/load_spec.rb for payloads/singles testing
  # @see spec/lib/metasploit/cache/module/instance/load_spec.rb for payloads/stages testing
  # @see spec/lib/metasploit/cache/module/instance/load_spec.rb for payloads/stagers testing
end