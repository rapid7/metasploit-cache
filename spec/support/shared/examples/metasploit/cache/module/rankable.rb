shared_examples_for 'Metasploit::Cache::Module::Rankable' do |rank:|
  context 'associations' do
    it { is_expected.to belong_to(:rank).class_name('Metasploit::Cache::Module::Rank').inverse_of(rank.fetch(:inverse_of) ) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :rank }
  end
end