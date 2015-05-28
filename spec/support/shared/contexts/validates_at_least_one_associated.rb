# validate_length_of from shoulda-matchers assumes attribute is String and doesn't work on associations
RSpec.shared_examples_for 'validates at least one associated' do |association, factory:|
  association_count_key = "#{association.to_s.singularize}_count".to_sym

  let(:error) {
    I18n.translate!(
        "#{described_class.i18n_scope}.errors.models.#{described_class.model_name.i18n_key}.attributes.#{association}.too_short",
        count: 1
    )
  }

  context "without #{association}" do
    subject(:instance) {
      FactoryGirl.build(
          factory,
          association_count_key => 0
      )
    }

    it "adds error on ###{association}" do
      instance.valid?

      expect(instance.errors[association]).to include(error)
    end
  end

  context "with #{association}" do
    subject(:instance) {
      FactoryGirl.build(
          factory,
          association_count_key => 1
      )
    }

    it "does not adds error on ###{association}" do
      instance.valid?

      expect(instance.errors[association]).not_to include(error)
    end
  end
end
