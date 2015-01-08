shared_examples_for 'Metasploit::Cache::Batch::Descendant' do
  context '#batched?' do
    subject(:batched?) do
      base_instance.batched?
    end

    context 'inside Metasploit::Cache::Batch.batch' do
      include_context 'Metasploit::Cache::Batch.batch'

      it { is_expected.to eq(true) }
    end

    context 'outside Metasploit::Cache::Batch.batch' do
      it { is_expected.to eq(false) }
    end
  end
end