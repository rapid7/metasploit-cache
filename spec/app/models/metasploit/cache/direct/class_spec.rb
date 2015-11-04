RSpec.describe Metasploit::Cache::Direct::Class, type: :model do
  context 'database' do
    context 'columns' do
      it { is_expected.to have_db_column(:ancestor_id).of_type(:integer).with_options(null: false) }
      it { is_expected.to have_db_column(:rank_id).of_type(:integer).with_options(null: false) }
    end

    context 'indices' do
      it { is_expected.to have_db_index([:ancestor_id]).unique(true) }
    end
  end

  context 'validations' do
    subject(:direct_class) {
      FactoryGirl.build(direct_class_factory)
    }

    let(:direct_class_factory) {
      FactoryGirl.generate :metasploit_cache_direct_class_factory
    }

    it { is_expected.to validate_presence_of(:ancestor) }
    it { is_expected.to validate_uniqueness_of(:ancestor_id) }
    it { is_expected.to validate_presence_of(:rank) }

    context 'is expected to validation uniqueness of #ancestor_id' do
      subject(:new_direct_class) {
        FactoryGirl.build(
            :metasploit_cache_auxiliary_class,
            ancestor: existing_ancestor
        )
      }


      #
      # lets
      #

      let(:error) {
        I18n.translate!('errors.messages.taken')
      }

      let(:existing_ancestor) {
        FactoryGirl.create(:metasploit_cache_auxiliary_ancestor)
      }

      #
      # let!s
      #

      let!(:existing_direct_class) {
        FactoryGirl.create(
            :metasploit_cache_auxiliary_class,
            ancestor: existing_ancestor
        )
      }

      context 'with batched' do
        include Metasploit::Cache::Spec::Matcher
        include_context 'Metasploit::Cache::Batch.batch'

        it 'does not add error on #ancestor_id' do
          new_direct_class.valid?

          expect(new_direct_class.errors[:ancestor_id]).not_to include(error)
        end

        it 'raises adapter-specific record not unique exception when saved' do
          expect {
            new_direct_class.save
          }.to raise_record_not_unique
        end
      end

      context 'without batched' do
        it 'records error on #ancestor_id' do
          new_direct_class.valid?

          expect(new_direct_class.errors[:ancestor_id]).to include(error)
        end
      end
    end
  end

  context 'traits' do
    context ':metasploit_cache_direct_class_ancestor_contents' do
      context 'with ancestor_contents?' do
        context 'without #ancestor' do
          subject(:direct_class) {
            FactoryGirl.build(
                :metasploit_cache_auxiliary_class,
                ancestor: nil,
                ancestor_contents?: true
            )
          }

          specify {
            expect {
              direct_class
            }.to raise_error ArgumentError,
                             "Metasploit::Cache::Auxiliary::Class#ancestor is `nil` and content cannot be written.  " \
                             "If this is expected, set `ancestor_contents?: false` when using the " \
                             ":metasploit_cache_direct_class_ancestor_contents trait."
          }
        end

        context 'with #ancestor' do
          context 'with Metasploit::Cache::Module::Ancestor#real_pathname' do
            subject(:direct_class) {
              FactoryGirl.build(
                  :metasploit_cache_auxiliary_class,
                  ancestor: module_ancestor,
                  ancestor_contents?: true
              )
            }

            let(:module_ancestor) {
              FactoryGirl.build(:metasploit_cache_auxiliary_ancestor)
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
                  :metasploit_cache_auxiliary_class,
                  ancestor_contents?: true,
                  ancestor: module_ancestor
              )
            }

            let(:module_ancestor) {
              FactoryGirl.build(
                             :metasploit_cache_auxiliary_ancestor,
                             content?: false,
                             relative_path: nil
              )
            }

            specify {
              expect {
                direct_class
              }.to raise_error ArgumentError,
                               "Metasploit::Cache::Auxiliary::Ancestor#real_pathname is `nil` and content cannot be " \
                               "written.  If this is expected, set `ancestor_contents?: false` when using the " \
                               ":metasploit_cache_direct_class_ancestor_contents trait."
            }
          end
        end
      end

      context 'without ancestor_contents?' do
        context 'without #ancestor' do
          subject(:direct_class) {
            FactoryGirl.build(
                :metasploit_cache_auxiliary_class,
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
                  :metasploit_cache_auxiliary_class,
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
                  :metasploit_cache_auxiliary_class,
                  ancestor: module_ancestor,
                  ancestor_contents?: false
              )
            }

            let(:module_ancestor) {
              FactoryGirl.build(
                             :metasploit_cache_auxiliary_ancestor,
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