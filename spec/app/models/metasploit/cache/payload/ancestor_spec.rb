RSpec.describe Metasploit::Cache::Payload::Ancestor do
  it_should_behave_like 'Metasploit::Cache::Module::Ancestor.restrict',
                        module_type: 'payload',
                        module_type_directory: 'payloads'
  it_should_behave_like 'Metasploit::Concern.run'

  context 'factories' do
    context 'metasploit_cache_payload_ancestor' do
      subject(:metasploit_cache_payload_ancestor) {
        FactoryGirl.build(:metasploit_cache_payload_ancestor)
      }

      it { is_expected.to be_valid }

      context 'with :payload_type' do
        subject(:metasploit_cache_payload_ancestor) {
          FactoryGirl.build(
                         :metasploit_cache_payload_ancestor,
                         payload_type: expected_payload_type
          )
        }

        context 'single' do
          let(:expected_payload_type) {
            'single'
          }

          it { is_expected.to be_valid }

          context '#payload_type' do
            subject(:payload_type) {
              metasploit_cache_payload_ancestor.payload_type
            }

            it { is_expected.to eq(expected_payload_type) }
          end
        end

        context 'stage' do
          let(:expected_payload_type) {
            'stage'
          }

          it { is_expected.to be_valid }

          context '#payload_type' do
            subject(:payload_type) {
              metasploit_cache_payload_ancestor.payload_type
            }

            it { is_expected.to eq(expected_payload_type) }
          end
        end

        context 'stager' do
          let(:expected_payload_type) {
            'stager'
          }

          it { is_expected.to be_valid }

          context '#payload_type' do
            subject(:payload_type) {
              metasploit_cache_payload_ancestor.payload_type
            }

            it { is_expected.to eq(expected_payload_type) }
          end
        end
      end
    end
  end

  context '#payload_type' do
    subject(:payload_type) {
      metasploit_cache_payload_ancestor.payload_type
    }

    let(:metasploit_cache_payload_ancestor) {
      FactoryGirl.build(
          :metasploit_cache_payload_ancestor,
          reference_name: reference_name
      )
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
                     :metasploit_cache_payload_ancestor,
                     relative_path: relative_path
      )
    }

    context 'with #relative_path' do
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
      let(:relative_path) {
        nil
      }

      it { is_expected.to be_nil }
    end
  end
end