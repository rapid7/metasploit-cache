RSpec.describe Metasploit::Cache::Direct::Class do
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
        I18n.translate!('activerecord.errors.messages.taken')
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
end