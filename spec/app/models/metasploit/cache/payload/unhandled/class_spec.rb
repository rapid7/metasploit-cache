RSpec.describe Metasploit::Cache::Payload::Unhandled::Class, type: :model do
  it 'is a subclass of Metasploit::Cache::Direct::Class' do
    expect(described_class).to be < Metasploit::Cache::Direct::Class
  end

  context 'traits' do
    context ':metasploit_cache_payload_unhandled_class_ancestor_contents' do
      context 'with ancestor_contents?' do
        context 'without #ancestor' do
          subject(:direct_class) {
            FactoryGirl.build(
                :metasploit_cache_payload_single_unhandled_class,
                ancestor: nil,
                ancestor_contents?: true
            )
          }

          specify {
            expect {
              direct_class
            }.to raise_error ArgumentError,
                             "Metasploit::Cache::Payload::Single::Unhandled::Class#ancestor is `nil` and " \
                             "content cannot be written.  If this is expected, set `ancestor_contents?: false` " \
                             "when using the :metasploit_cache_payload_unhandled_class_ancestor_contents trait."
          }
        end

        context 'with #ancestor' do
          context 'with Metasploit::Cache::Module::Ancestor#real_pathname' do
            subject(:direct_class) {
              FactoryGirl.build(
                  :metasploit_cache_payload_single_unhandled_class,
                  ancestor: module_ancestor,
                  ancestor_contents?: true
              )
            }

            let(:module_ancestor) {
              FactoryGirl.build(:metasploit_cache_payload_single_ancestor)
            }

            it 'does write file' do
              expect {
                direct_class
              }.to change {
                     # CANNOT access direct_class as it will call after(:build) call back under test
                     module_ancestor.real_pathname.size
                   }
            end
          end

          context 'without Metasploit::Cache::Module::Ancestor#real_pathname' do
            subject(:direct_class) {
              FactoryGirl.build(
                  :metasploit_cache_payload_single_unhandled_class,
                  ancestor_contents?: true,
                  ancestor: module_ancestor
              )
            }

            let(:module_ancestor) {
              FactoryGirl.build(
                             :metasploit_cache_payload_single_ancestor,
                             content?: false,
                             relative_path: nil
              )
            }

            specify {
              expect {
                direct_class
              }.to raise_error ArgumentError,
                               "Metasploit::Cache::Payload::Single::Ancestor#real_pathname is `nil` and " \
                               "content cannot be written.  If this is expected, set `ancestor_contents?: false` " \
                               "when using the :metasploit_cache_payload_unhandled_class_ancestor_contents trait."
            }
          end
        end
      end

      context 'without ancestor_contents?' do
        context 'without #ancestor' do
          subject(:direct_class) {
            FactoryGirl.build(
                :metasploit_cache_payload_single_unhandled_class,
                ancestor: false,
                ancestor_contents?: false
            )
          }

          specify {
            expect {
              direct_class
            }.not_to raise_error
          }
        end

        context 'with #ancestor' do
          context 'with Metasploit::Cache::Module::Ancestor#real_pathname' do
            subject(:direct_class) {
              FactoryGirl.build(
                  :metasploit_cache_payload_single_unhandled_class,
                  ancestor_contents?: false
              )
            }

            it 'does not write file' do
              expect {
                direct_class
              }.not_to change { direct_class.ancestor.real_pathname.size }
            end
          end

          context 'without Metasploit::Cache::Module::Ancestor#real_pathname' do
            subject(:direct_class) {
              FactoryGirl.build(
                  :metasploit_cache_payload_single_unhandled_class,
                  ancestor: module_ancestor,
                  ancestor_contents?: false
              )
            }

            let(:module_ancestor) {
              FactoryGirl.build(
                             :metasploit_cache_payload_single_ancestor,
                             content?: false,
                             relative_path: nil
              )
            }

            specify {
              expect {
                direct_class
              }.not_to raise_error
            }
          end
        end
      end
    end
  end
end