shared_examples_for 'search query with Metasploit::Model::Search::Operator::Deprecated::App' do
  context 'with app' do
    subject(:query) do
      Metasploit::Model::Search::Query.new(
          :formatted => formatted,
          :klass => base_class
      )
    end

    let(:formatted) do
      "app:#{formatted_value}"
    end

    context 'operations' do
      subject(:operations) do
        query.operations
      end

      context 'stance' do
        subject(:operation) do
          operations.find { |operation|
            operation.operator.name == :stance
          }
        end

        context 'with client' do
          let(:formatted_value) do
            'client'
          end

          it "has value of 'passive'" do
            expect(operation.value).to eq('passive')
          end
        end

        context 'with server' do
          let(:formatted_value) do
            'server'
          end

          it "has value of 'aggressive'" do
            expect(operation.value).to eq('aggressive')
          end
        end
      end
    end
  end
end