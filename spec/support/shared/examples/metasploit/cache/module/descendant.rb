shared_examples_for 'Metasploit::Cache::Module::Descendant' do |ancestor:, factory:|
  context 'associations' do
    it { is_expected.to belong_to(:ancestor).class_name(ancestor.fetch(:class_name)).inverse_of(ancestor.fetch(:inverse_of)) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:ancestor) }

    context 'with existing record' do
      let!(:existing_module_descendant) {
        FactoryGirl.create(factory)
      }

      it { is_expected.to validate_uniqueness_of(:ancestor_id) }
    end
  end
end