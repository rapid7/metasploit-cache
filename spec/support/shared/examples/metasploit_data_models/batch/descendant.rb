shared_examples_for 'MetasploitDataModels::Batch::Descendant' do
  context '#batched?' do
    subject(:batched?) do
      base_instance.batched?
    end

    context 'inside MetasploitDataModels::Batch.batch' do
      include_context 'MetasploitDataModels::Batch.batch'

      it { is_expected.to eq(true) }
    end

    context 'outside MetasploitDataModels::Batch.batch' do
      it { is_expected.to eq(false) }
    end
  end
end