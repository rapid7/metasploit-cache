RSpec.describe Metasploit::Cache::Payload::Ancestor do
  it_should_behave_like 'Metasploit::Cache::Module::Ancestor.restrict',
                        module_type: 'payload',
                        module_type_directory: 'payloads' do
    let(:described_class) {
      [
          Metasploit::Cache::Payload::Single::Ancestor,
          Metasploit::Cache::Payload::Stage::Ancestor,
          Metasploit::Cache::Payload::Stager::Ancestor,
      ].sample
    }
  end

  it_should_behave_like 'Metasploit::Concern.run'

  context 'traits' do
    context ':metasploit_cache_payload_ancestor_content' do
      context 'with content?' do
        context 'with #real_pathname' do
          subject(:payload_ancestor) {
            FactoryGirl.build(
                           :metasploit_cache_payload_single_ancestor,
                           content?: true,
                           parent_path: parent_path,
                           relative_path: relative_path
            )
          }

          let(:parent_path) {
            FactoryGirl.build(:metasploit_cache_module_path)
          }

          let(:relative_path) {
            'payloads/singles/payload/name.rb'
          }

          it 'write file' do
            expect {
              payload_ancestor
            }.to change { parent_path.real_pathname.join(relative_path).exist? }.from(false).to(true)
          end
        end

        context 'without #real_pathnam' do
          subject(:payload_ancestor) {
            FactoryGirl.build(
                :metasploit_cache_payload_single_ancestor,
                content?: true,
                relative_path: nil
            )
          }

          specify {
            expect {
              payload_ancestor
            }.to raise_error ArgumentError,
                             "Metasploit::Cache::Payload::Single::Ancestor#real_pathname is `nil` and " \
                             "content cannot be written.  If this is expected, set `content?: false` " \
                             "when using the :metasploit_cache_payload_ancestor_content trait."
          }
        end
      end

      context 'without content?' do
        context 'with #real_pathname' do
          subject(:payload_ancestor) {
            FactoryGirl.build(
                           :metasploit_cache_payload_single_ancestor,
                           content?: false,
                           parent_path: parent_path,
                           relative_path: relative_path
            )
          }

          let(:parent_path) {
            FactoryGirl.build(:metasploit_cache_module_path)
          }

          let(:relative_path) {
            'payloads/singles/payload/name.rb'
          }

          it 'does not write file' do
            expect {
              payload_ancestor
            }.not_to change { parent_path.real_pathname.join(relative_path).exist? }.from(false)
          end
        end

        context 'without #real_pathnam' do
          subject(:payload_ancestor) {
            FactoryGirl.build(
                :metasploit_cache_payload_single_ancestor,
                content?: false,
                relative_path: nil
            )
          }

          specify {
            expect {
              payload_ancestor
            }.not_to raise_error
          }
        end
      end
    end
  end

  context '#initialize' do
    it 'prevents initialization of Metasploit::Cache::Payload::Ancestors' do
      expect {
        described_class.new
      }.to raise_error(TypeError)
    end
  end

  context '#payload_type' do
    subject(:payload_type) {
      payload_ancestor.payload_type
    }

    let(:payload_ancestor) {
      FactoryGirl.build(
          payload_ancestor_factory,
          reference_name: reference_name
      )
    }

    let(:payload_ancestor_factory) {
      FactoryGirl.generate :metasploit_cache_payload_ancestor_factory
    }

    context 'with #reference_name starting with' do
      context "'singles'" do
        let(:reference_name) {
          'singles/module.rb'
        }

        it { is_expected.to eq('single') }
      end

      context "'stages'" do
        let(:reference_name) {
          'stages/module.rb'
        }

        it { is_expected.to eq('stage') }
      end

      context "'stagers'" do
        let(:reference_name) {
          'stagers/module.rb'
        }

        it { is_expected.to eq('stager') }
      end
    end
  end

  context '#payload_type_directory' do
    subject(:payload_type_directory) {
      payload_ancestor.payload_type_directory
    }

    let(:payload_ancestor) {
      FactoryGirl.build(
                     payload_ancestor_factory,
                     content?: content?,
                     relative_path: relative_path
      )
    }

    let(:payload_ancestor_factory) {
      FactoryGirl.generate :metasploit_cache_payload_ancestor_factory
    }

    context 'with #relative_path' do
      let(:content?) {
        true
      }

      let(:first_relative_file_name) {
        'payload'
      }

      let(:rest_relative_file_names) {
        'cache/module/ancestor/reference/name.rb'
      }

      let(:second_relative_file_name) {
        'second_relative_file_name'
      }

      let(:relative_path) {
        "#{first_relative_file_name}/#{second_relative_file_name}/#{rest_relative_file_names}"
      }

      it 'is second relative file name' do
        expect(payload_type_directory).to eq(second_relative_file_name)
      end
    end

    context 'without #relative_path' do
      let(:content?) {
        false
      }

      let(:relative_path) {
        nil
      }

      it { is_expected.to be_nil }
    end
  end
end