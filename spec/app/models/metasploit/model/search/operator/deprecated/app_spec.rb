require 'spec_helper'

RSpec.describe Metasploit::Model::Search::Operator::Deprecated::App do
  subject(:operator) do
    described_class.new(
        :klass => klass
    )
  end

  let(:klass) do
    Class.new
  end

  it { should be_a Metasploit::Model::Search::Operator::Delegation }

  context 'CONSTANTS' do
    context 'STANCE_BY_APP' do
      subject(:stance_by_app) do
        described_class::STANCE_BY_APP
      end

      it "maps 'client' to 'passive'" do
        expect(stance_by_app['client']).to eq('passive')
      end

      it "maps 'server' to 'aggressive'" do
        expect(stance_by_app['server']).to eq('aggressive')
      end
    end
  end

  context '#operate_on' do
    subject(:operation) do
      operator.operate_on(formatted_value)
    end

    let(:stance_operator) do
      Metasploit::Model::Search::Operator::Attribute.new(
          :attribute => :stance,
          :klass => klass,
          :type => :string
      )
    end

    before(:each) do
      allow(operator).to receive(:operator).with('stance').and_return(stance_operator)
    end

    context 'with client' do
      let(:formatted_value) do
        'client'
      end

      it 'has operator.name of :stance' do
        expect(operation.operator.name).to eq(:stance)
      end

      it "has value of 'passive'" do
        expect(operation.value).to eq('passive')
      end
    end

    context 'with server' do
      let(:formatted_value) do
        'server'
      end

      it 'has operator.name of :stance' do
        expect(operation.operator.name).to eq(:stance)
      end

      it "has value of 'passive'" do
        expect(operation.value).to eq('aggressive')
      end
    end
  end
end