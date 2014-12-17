Metasploit::Model::Spec.shared_examples_for 'Module::Author' do
  full_module_author_factory = "full_#{module_author_factory}"

  context 'factories' do
    context module_author_factory do
      subject(module_author_factory) do
        FactoryGirl.build(module_author_factory)
      end

      it { should be_valid }
    end

    context full_module_author_factory do
      subject(full_module_author_factory) do
        FactoryGirl.build(full_module_author_factory)
      end

      it { should be_valid }

      it 'has email_address' do
        expect(send(full_module_author_factory).send(:email_address)).not_to be_nil
      end
    end
  end

  context 'validations' do
    it { should validate_presence_of(:author) }
    it { should validate_presence_of(:module_instance) }
    it { should_not validate_presence_of(:email_address) }
  end
end