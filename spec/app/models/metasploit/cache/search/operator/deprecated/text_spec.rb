RSpec.describe Metasploit::Cache::Search::Operator::Deprecated::Text do
  subject(:operator) do
    described_class.new(
        :klass => klass
    )
  end

  let(:klass) do
    Class.new
  end

  context 'CONSTANTS' do
    context 'OPERATOR_NAMES' do
      subject(:operator_names) do
        described_class::OPERATOR_NAMES
      end

      it { should include 'description' }
      it { should include 'name' }
    end
  end

  context '#children' do
    include_context 'Metasploit::Model::Search::Operator::Group::Union#children'

    let(:description_operator) do
      Metasploit::Model::Search::Operator::Attribute.new(
          :attribute => :description,
          :klass => klass,
          :type => :string
      )
    end

    let(:formatted_value) do
      'value'
    end

    let(:name_operator) do
      Metasploit::Model::Search::Operator::Attribute.new(
          :attribute => :name,
          :klass => klass,
          :type => :string
      )
    end

    let(:target_class) do
      Class.new
    end

    let(:target_name_operator) do
      Metasploit::Model::Search::Operator::Attribute.new(
          :attribute => :name,
          :klass => target_class,
          :type => :string
      )
    end

    let(:targets_name_operator) do
      Metasploit::Model::Search::Operator::Association.new(
          :association => :targets,
          :source_operator => target_name_operator,
          :klass => klass
      )
    end

    before(:each) do
      allow(operator).to receive(:operator).with('description').and_return(description_operator)
      allow(operator).to receive(:operator).with('name').and_return(name_operator)
    end

    context 'description' do
      subject(:operation) do
        child('description')
      end

      it 'should use formatted value for value' do
        expect(operation.value).to eq(formatted_value)
      end
    end

    context 'name' do
      subject(:operation) do
        child('name')
      end

      it 'should use formatted value for value' do
        expect(operation.value).to eq(formatted_value)
      end
    end
  end
end