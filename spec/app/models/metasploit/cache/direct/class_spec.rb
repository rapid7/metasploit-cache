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
end