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

  context 'remove' do
    subject(:remove) {
      described_class.remove(names)
    }

    #
    # lets
    #

    let(:names) {
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
        expect(remove.name).to eq('Grandparent::Parent::Child')
      end

      it 'removes the named Module' do
        expect {
          remove
        }.to change { defined? Grandparent::Parent::Child }.from('constant').to(nil)
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

  context 'swap_on_parent' do
    subject(:swap_on_parent) {
      described_class.swap_on_parent(
          constant: constant,
          parent: parent,
          relative_name: relative_name
      )
    }

    let(:relative_name) {
      'Child'
    }

    context 'with parent_module' do
      #
      # lets
      #

      let(:parent) {
        Grandparent::Parent
      }

      #
      # Callbacks
      #

      before(:each) do
        module Grandparent
          module Parent

          end
        end
      end

      after(:each) do
        if defined? Grandparent
          Object.send(:remove_const, :Grandparent)
        end
      end

      context 'with current constant' do
        context 'with different from :constant' do
          before(:each) do
            parent::Child = Module.new
          end

          context 'with same as :constant' do
            let(:constant) {
              Module.new do
                def self.version
                  1
                end
              end
            }

            it 'swaps to :constant' do
              swap_on_parent

              expect(Grandparent::Parent::Child).to eq(constant)
              expect(constant.version).to eq(1)
            end
          end

          context 'without :constant' do
            let(:constant) {
              nil
            }

            it 'it removes new module and does not set constant to nil' do
              swap_on_parent

              expect(defined? Grandparent::Parent::Child).to be_nil
            end
          end
        end

        context 'with same as :constant' do
          #
          # lets
          #

          let(:constant) {
            Grandparent::Parent::Child
          }

          #
          # Callbacks
          #

          before(:each) do
            parent::Child = Module.new do
              def self.version
                1
              end
            end
          end

          it 'does not remove and then reset constant as it is unnecessary' do
            expect(parent).not_to receive(:remove_const)
            expect(parent).not_to receive(:const_set)

            swap_on_parent

            expect(constant.version).to eq(1)
          end
        end
      end

      context 'without current constant' do
        context 'with :constant' do
          #
          # lets
          #

          let(:constant) {
            Module.new do
              def self.version
                1
              end
            end
          }

          it 'sets constant to :constant' do
            swap_on_parent

            expect(Grandparent::Parent::Child).to eq(constant)
            expect(constant.version).to eq(1)
          end
        end

        context 'without :constant' do
          let(:constant) {
            nil
          }

          it 'does not set constant' do
            swap_on_parent

            expect(defined? Grandparent::Parent::Child).to be_nil
          end
        end
      end
    end
  end
end