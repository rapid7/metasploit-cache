shared_examples_for 'Metasploit::Cache::Module::Class::Namable' do
  context 'associations' do
    it { is_expected.to have_one(:name).class_name('Metasploit::Cache::Module::Class::Name').dependent(:destroy).inverse_of(:module_class).with_foreign_key(:module_class_id) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :name }
  end
end