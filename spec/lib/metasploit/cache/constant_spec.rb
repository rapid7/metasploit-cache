RSpec.describe Metasploit::Cache::Constant do
  context 'current' do
    subject(:current) {
      described_class.current(module_names)
    }

    #
    # lets
    #

    let(:module_names) {
      ['Grandparent', 'Parent', 'Child']
    }

    #
    # Callbacks
    #

    after(:each) do
      if defined? Grandparent
        Object.send(:remove_const, :Grandparent)
      end
    end

    context 'with all module_names defined' do
      before(:each) do
        module Grandparent
          module Parent
            module Child

            end
          end
        end
      end

      it 'is named Module' do
        expect(current).to eq(Grandparent::Parent::Child)
      end
    end

    context 'with some module_names defined' do
      before(:each) do
        module Grandparent
          module Parent

          end
        end
      end

      it { is_expected.to be_nil }
    end

    context 'without any module_names defined' do
      it { is_expected.to be_nil }
    end
  end
end