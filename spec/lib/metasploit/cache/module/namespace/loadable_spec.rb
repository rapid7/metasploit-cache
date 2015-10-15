RSpec.describe Metasploit::Cache::Module::Namespace::Loadable do
  let(:base_module) {
    context_described_class = described_class

    Module.new do
      extend context_described_class
    end
  }

  context 'load' do
    context 'with memoized' do
      #
      # lets
      #

      let(:persister_class) {
        double('Persister Class')
      }

      #
      # Callbacks
      #

      before(:each) do
        base_module.load(persister_class: persister_class)
      end

      context 'with :persister_class' do
        it 'raises ArgumentError' do
          expect {
            base_module.load(persister_class: persister_class)
          }.to raise_error(ArgumentError)
        end
      end

      context 'without :persister_class' do
        it 'returns a Metasploit::Cache::Module::Namespace::Load' do
          expect(base_module.load).to be_a Metasploit::Cache::Module::Namespace::Load
        end

        context 'Metasploit::Cache::Module::Namespace::Load' do
          subject(:module_namespace_load) {
            base_module.load
          }

          context '#module_namespace' do
            subject(:module_namesapce) {
              module_namespace_load.module_namespace
            }

            it "is load's receiver" do
              expect(module_namesapce).to eq(base_module)
            end
          end

          context '#persister_class' do
            subject(:module_namespace_load_persister_class) {
              module_namespace_load.persister_class
            }

            it 'is given :persister_class' do
              expect(module_namespace_load_persister_class).to eq(persister_class)
            end
          end
        end
      end
    end

    context 'without memoized' do
      context 'with :persister_class' do
        let(:persister_class) {
          double('Persister Class')
        }

        it 'returns a Metasploit::Cache::Module::Namespace::Load' do
          expect(base_module.load(persister_class: persister_class)).to be_a Metasploit::Cache::Module::Namespace::Load
        end

        context 'Metasploit::Cache::Module::Namespace::Load' do
          subject(:module_namespace_load) {
            base_module.load(persister_class: persister_class)
          }

          context '#module_namespace' do
            subject(:module_namesapce) {
              module_namespace_load.module_namespace
            }

            it "is load's receiver" do
              expect(module_namesapce).to eq(base_module)
            end
          end

          context '#persister_class' do
            subject(:module_namespace_load_persister_class) {
              module_namespace_load.persister_class
            }

            it 'is given :persister_class' do
              expect(module_namespace_load_persister_class).to eq(persister_class)
            end
          end
        end
      end

      context 'without :persister_class' do
        it 'raises KeyError' do
          expect {
            base_module.load
          }.to raise_error(KeyError)
        end
      end
    end
  end
end