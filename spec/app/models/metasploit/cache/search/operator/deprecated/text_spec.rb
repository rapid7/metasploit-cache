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

      it 'should include platform instead of platforms.fully_qualified_name and targets.name' do
        expect(operator_names).to include('platform')
        expect(operator_names).not_to include('platforms.fully_qualified_name')
        expect(operator_names).not_to include('targets.name')
      end

      it 'should include ref instead of authors.name, references.designation and references.url to handle deprecated reference syntax' do
        expect(operator_names).to include('ref')
        expect(operator_names).not_to include('authors.name')
        expect(operator_names).not_to include('references.designation')
        expect(operator_names).not_to include('references.url')
      end
    end
  end

  context '#children' do
    include_context 'Metasploit::Model::Search::Operator::Group::Union#children'

    let(:architecture_class) do
      Class.new
    end

    let(:architecture_abbreviation_operator) do
      Metasploit::Model::Search::Operator::Attribute.new(
          :attribute => :abbreviation,
          :klass => architecture_class,
          :type => :string
      )
    end

    let(:architectures_abbreviation_operator) do
      Metasploit::Model::Search::Operator::Association.new(
          :association => :architectures,
          :source_operator => architecture_abbreviation_operator,
          :klass => klass
      )
    end

    let(:authority_class) do
      Class.new
    end

    let(:authority_abbreviation_operator) do
      Metasploit::Model::Search::Operator::Attribute.new(
          :attribute => :abbreviation,
          :klass => authority_class,
          :type => :string
      )
    end

    let(:authorities_abbreviation_operator) do
      Metasploit::Model::Search::Operator::Association.new(
          :association => :authorities,
          :source_operator => authority_abbreviation_operator,
          :klass => klass
      )
    end

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

    let(:platform_class) do
      Class.new
    end

    let(:platform_operator) do
      Metasploit::Cache::Search::Operator::Deprecated::Platform.new(
          :klass => klass,
          :name => :platform
      )
    end

    let(:platform_fully_qualified_name_operator) do
      Metasploit::Model::Search::Operator::Attribute.new(
          :attribute => :fully_qualified_name,
          :klass => platform_class,
          :type => :string
      )
    end

    let(:platforms_fully_qualified_name_operator) do
      Metasploit::Model::Search::Operator::Association.new(
          :association => :platforms,
          :source_operator => platform_fully_qualified_name_operator,
          :klass => klass
      )
    end

    let(:ref_operator) do
      Metasploit::Cache::Search::Operator::Deprecated::Ref.new(
          :klass => klass
      )
    end

    let(:reference_class) do
      Class.new
    end

    let(:reference_designation_operator) do
      Metasploit::Model::Search::Operator::Attribute.new(
          :attribute => :designation,
          :klass => reference_class,
          :type => :string
      )
    end

    let(:references_designation_operator) do
      Metasploit::Model::Search::Operator::Association.new(
          :association => :references,
          :source_operator => reference_designation_operator,
          :klass => klass
      )
    end

    let(:reference_url_operator) do
      Metasploit::Model::Search::Operator::Attribute.new(
          :attribute => :url,
          :klass => reference_class,
          :type => :string
      )
    end

    let(:references_url_operator) do
      Metasploit::Model::Search::Operator::Association.new(
          :association => :references,
          :source_operator => reference_url_operator,
          :klass => klass
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
      allow(operator).to receive(:operator).with('architectures.abbreviation').and_return(architectures_abbreviation_operator)
      allow(operator).to receive(:operator).with('platform').and_return(platform_operator)
      allow(operator).to receive(:operator).with('ref').and_return(ref_operator)

      allow(platform_operator).to receive(:operator).with(
          'platforms.fully_qualified_name'
      ).and_return(
          platforms_fully_qualified_name_operator
      )
      allow(platform_operator).to receive(:operator).with('targets.name').and_return(targets_name_operator)

      allow(ref_operator).to receive(:operator).with('authorities.abbreviation').and_return(authorities_abbreviation_operator)
      allow(ref_operator).to receive(:operator).with('references.designation').and_return(references_designation_operator)
      allow(ref_operator).to receive(:operator).with('references.url').and_return(references_url_operator)
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

    context 'architectures.abbreviation' do
      subject(:operation) do
        child('architectures.abbreviation')
      end

      context 'Metasploit::Model::Search::Operation::Association#source_operation' do
        subject(:source_operation) {
          operation.source_operation
        }

        it 'should use formatted value for value' do
          expect(source_operation.value).to eq(formatted_value)
        end
      end
    end

    context 'platform' do
      subject(:child_operation) do
        child('platform')
      end

      context 'children' do
        subject(:grandchildren) do
          child_operation.children
        end

        def grandchild(formatted_operator)
          grandchildren.find { |operation|
            operation.operator.name == formatted_operator.to_sym
          }
        end

        context 'platforms.fully_qualified_name' do
          subject(:grandchild_operation) do
            grandchild('platforms.fully_qualified_name')
          end

          context 'Metasploit::Model::Search::Operation::Association#source_operation' do
            subject(:source_operation) {
              grandchild_operation.source_operation
            }

            it 'should use formatted value for value' do
              expect(source_operation.value).to eq(formatted_value)
            end
          end
        end

        context 'targets.name' do
          subject(:grandchild_operation) do
            grandchild('targets.name')
          end

          context 'Metasploit::Model::Search::Operation::Association#source_operation' do
            subject(:source_operation) {
              grandchild_operation.source_operation
            }

            it 'should use formatted value for value' do
              expect(source_operation.value).to eq(formatted_value)
            end
          end
        end
      end
    end

    context 'ref' do
      subject(:child_operation) do
        child('ref')
      end

      context 'children' do
        subject(:grandchildren) do
          child_operation.children
        end

        def grandchild(formatted_operator)
          grandchildren.find { |operation|
            operation.operator.name == formatted_operator.to_sym
          }
        end

        context 'authorities.abbreviation' do
          subject(:grandchild_operation) do
            grandchild('authorities.abbreviation')
          end

          context 'Metasploit::Model::Search::Operation::Association#source_operation' do
            subject(:source_operation) {
              grandchild_operation.source_operation
            }

            it 'should use formatted value for value' do
              expect(source_operation.value).to eq(formatted_value)
            end
          end
        end

        context 'references.designation' do
          subject(:grandchild_operation) do
            grandchild('references.designation')
          end

          context 'Metasploit::Model::Search::Operation::Association#source_operation' do
            subject(:source_operation) {
              grandchild_operation.source_operation
            }

            it 'should use formatted value for value' do
              expect(source_operation.value).to eq(formatted_value)
            end
          end
        end

        context 'references.url' do
          subject(:grandchild_operation) do
            grandchild('references.url')
          end

          context 'Metasploit::Model::Search::Operation::Association#source_operation' do
            subject(:source_operation) {
              grandchild_operation.source_operation
            }

            it 'should use formatted value for value' do
              expect(source_operation.value).to eq(formatted_value)
            end
          end
        end
      end
    end
  end
end