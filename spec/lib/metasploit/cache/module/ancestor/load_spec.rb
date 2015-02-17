require 'file/find'

RSpec.describe Metasploit::Cache::Module::Ancestor::Load, :cache do
  include_context 'Metasploit::Cache::Module::Ancestor::Spec::Unload.unload'

  subject(:module_ancestor_load) do
    described_class.new(
        # This should match the major version number of metasploit-framework
        maximum_version: 4,
        module_ancestor: module_ancestor,
        logger: logger
    )
  end

  let(:logger) {
    ActiveSupport::TaggedLogging.new(
        Logger.new(logger_string_io)
    ).tap { |logger|
      logger.level = Logger::DEBUG
    }
  }

  let(:logger_string_io) {
    StringIO.new
  }

  let(:module_ancestor) do
    FactoryGirl.create(:metasploit_cache_module_ancestor)
  end

  context 'validations' do
    context 'metasploit_module' do
      context 'presence' do
        let(:error) do
          I18n.translate('errors.messages.blank')
        end

        before(:each) do
          allow(module_ancestor_load).to receive(:metasploit_module).and_return(metasploit_module)

          # for #module_ancestor_valid
          module_ancestor_load.valid?(validation_context)
        end

        context 'with :loading validation context' do
          let(:validation_context) do
            :loading
          end

          context 'with nil' do
            let(:metasploit_module) do
              nil
            end

            it 'should add error on :metasploit_module' do
              expect(module_ancestor_load.errors[:metasploit_module]).not_to include(error)
            end
          end

          context 'without nil' do
            let(:metasploit_module) do
              Module.new
            end

            it 'should not add error on :metasploit_module' do
              expect(module_ancestor_load.errors[:metasploit_module]).not_to include(error)
            end
          end
        end

        context 'without validation context' do
          let(:validation_context) do
            nil
          end

          context 'with nil' do
            let(:metasploit_module) do
              nil
            end

            it 'should add error on :metasploit_module' do
              expect(module_ancestor_load.errors[:metasploit_module]).to include(error)
            end
          end

          context 'without nil' do
            let(:metasploit_module) do
              Module.new do
                def self.is_usable
                  true
                end
              end
            end

            it 'should not add error on :metasploit_module' do
              expect(module_ancestor_load.errors[:metasploit_module]).not_to include(error)
            end
          end
        end
      end

      context 'usability' do
        let(:error) do
          I18n.translate('metasploit.model.errors.models.metasploit/cache/module/ancestor/load.attributes.metasploit_module.unusable')
        end

        before(:each) do
          allow(module_ancestor_load).to receive(:metasploit_module).and_return(metasploit_module)

          # for #module_ancestor_valid
          module_ancestor_load.valid?(validation_context)
        end

        context 'with :loading validation context' do
          let(:validation_context) do
            :loading
          end

          context 'with nil' do
            let(:metasploit_module) do
              nil
            end

            it 'should not add error on :metasploit_module' do
              expect(module_ancestor_load.errors[:metasploit_module]).not_to include(error)
            end
          end

          context 'without nil' do
            let(:metasploit_module) do
              Module.new
            end

            it 'should not add error on :metasploit_module' do
              expect(module_ancestor_load.errors[:metasploit_module]).not_to include(error)
            end
          end
        end

        context 'without validation context' do
          let(:validation_context) do
            nil
          end

          context 'with nil' do
            let(:metasploit_module) do
              nil
            end

            it 'should not add error on :metasploit_module' do
              expect(module_ancestor_load.errors[:metasploit_module]).not_to include(error)
            end
          end

          context 'without nil' do
            let(:metasploit_module) do
              usable = self.usable
              Module.new do
                define_singleton_method(:is_usable) do
                  usable
                end
              end
            end

            context 'with is_usable' do
              let(:usable) {
                true
              }

              it 'does not add error on :metasploit_module' do
                expect(module_ancestor_load.errors[:metasploit_module]).not_to include(error)
              end
            end

            context 'without is_usable' do
              let(:usable) {
                false
              }

              it 'adds error on :metasploit_module' do
                expect(module_ancestor_load.errors[:metasploit_module]).to include(error)
              end
            end
          end
        end
      end
    end

    context 'module_ancestor' do
      #it { should validate_presence_of :module_ancestor }

      context 'recursive' do
        let(:error) do
          I18n.translate('errors.messages.invalid')
        end

        context 'with nil' do
          before(:each) do
            module_ancestor_load.module_ancestor = nil
            module_ancestor_load.valid?
          end

          it 'should not add error on :module_ancestor' do
            expect(module_ancestor_load.errors[:module_ancestor]).not_to include(error)
          end
        end

        context 'without nil' do
          before(:each) do
            allow(module_ancestor).to receive(:invalid?).and_return(!valid?)
            allow(module_ancestor).to receive(:valid?).and_return(valid?)

            module_ancestor_load.valid?
          end

          context 'with valid' do
            let(:valid?) do
              true
            end

            it 'does not add error on :module_ancestor' do
              expect(module_ancestor_load.errors[:module_ancestor]).not_to include(error)
            end
          end

          context 'without valid' do
            let(:valid?) do
              false
            end

            it 'adds error on :module_ancestor' do
              expect(module_ancestor_load.errors[:module_ancestor]).to include(error)
            end
          end
        end
      end
    end
  end

  context '#loading_context?' do
    subject(:loading_context?) do
      module_ancestor_load.send(:loading_context?)
    end

    context 'with :loading validation_context' do
      it 'should be true' do
        expect(module_ancestor_load).to receive(:run_validations!) do
          expect(loading_context?).to eq(true)
        end

        module_ancestor_load.valid?(:loading)
      end
    end

    context 'without validation_context' do
      it 'should be false' do
        expect(module_ancestor_load).to receive(:run_validations!) do
          expect(loading_context?).to eq(false)
        end

        module_ancestor_load.valid?
      end
    end
  end

  context '#metasploit_module' do
    subject(:metasploit_module) do
      module_ancestor_load.metasploit_module
    end

    before(:each) do
      allow(module_ancestor_load).to receive(:namespace_module).and_return(namespace_module)
    end

    context 'with #namespace_module' do
      let(:namespace_module_metasploit_module) {
        double('Metasploit Module')
      }

      let(:namespace_module) {
        double(
            'Namespace Module',
            load: namespace_module_load
        )
      }

      let(:namespace_module_load) {
        instance_double(
            Metasploit::Cache::Module::Namespace::Load,
            metasploit_module: namespace_module_metasploit_module
        )
      }

      it 'should return namespace_module.metasploit_module' do
        expect(metasploit_module).to eq(namespace_module_metasploit_module)
      end
    end

    context 'without #namespace_module' do
      let(:namespace_module) do
        nil
      end

      it { should be_nil }
    end
  end

  context '#metasploit_module_usable' do
    subject(:metasploit_module_usable) do
      module_ancestor_load.send(:metasploit_module_usable)
    end

    let(:error) do
      I18n.translate('metasploit.model.errors.models.metasploit/cache/module/ancestor/load.attributes.metasploit_module.unusable')
    end

    before(:each) do
      allow(module_ancestor_load).to receive(:metasploit_module).and_return(metasploit_module)
    end

    context 'with #metasploit_module' do
      let(:metasploit_module) do
        double(
            'Metasploit Module',
            is_usable: is_usable
        )
      end

      context 'with is_usable' do
        let(:is_usable) {
          true
        }

        it 'should not add error on :metasploit_module' do
          metasploit_module_usable

          expect(module_ancestor_load.errors[:metasploit_module]).not_to include(error)
        end
      end

      context 'without is_usable' do
        let(:is_usable) {
          false
        }

        it 'should not add error on :metasploit_module' do
          metasploit_module_usable

          expect(module_ancestor_load.errors[:metasploit_module]).to include(error)
        end
      end
    end

    context 'without #metasploit_module' do
      let(:metasploit_module) do
        nil
      end

      it 'should not add error on :metasploit_module' do
        metasploit_module_usable

        expect(module_ancestor_load.errors[:metasploit_module]).not_to include(error)
      end
    end
  end

  context '#module_ancestor_valid' do
    subject(:module_ancestor_valid) do
      module_ancestor_load.send(:module_ancestor_valid)
    end

    let(:error) do
      I18n.translate('errors.messages.invalid')
    end

    context 'with #module_ancestor' do
      before(:each) do
        allow(module_ancestor).to receive(:invalid?).and_return(!valid?)
        allow(module_ancestor).to receive(:valid?).and_return(valid?)
      end

      context 'with valid' do
        let(:valid?) do
          true
        end

        it 'should not add error on :module_ancestor' do
          module_ancestor_valid

          expect(module_ancestor_load.errors[:module_ancestor]).not_to include(error)
        end
      end

      context 'without valid' do
        let(:valid?) do
          false
        end

        it 'should add error on :module_ancestor' do
          module_ancestor_valid

          expect(module_ancestor_load.errors[:module_ancestor]).to include(error)
        end
      end
    end

    context 'without #module_ancestor' do
      let(:module_ancestor) do
        nil
      end

      it 'should not add error on :module_ancestor' do
        module_ancestor_valid

        expect(module_ancestor_load.errors[:module_ancestor]).not_to include(error)
      end
    end
  end

  context '#namespace_module' do
    subject(:namespace_module) do
      module_ancestor_load.namespace_module
    end

    context 'with valid for loading' do
      it 'should be valid for loading' do
        expect(module_ancestor_load).to be_valid(:loading)
      end

      it 'should call namespace_module_transaction' do
        expect(Metasploit::Cache::Module::Namespace).to receive(:transaction).with(module_ancestor)

        namespace_module
      end

      context 'module_ancestor_eval' do
        let(:transaction_namespace_module) do
          double('Transaction Namespace Module').tap { |namespace_module|
            load = Metasploit::Cache::Module::Namespace::Load.new(
                module_namespace: namespace_module
            )
            allow(namespace_module).to receive(:errors).and_return(load.errors)
            allow(namespace_module).to receive(:load).and_return(load)

            allow(load).to receive(:module_ancestor_eval).with(module_ancestor).and_return(success)
            allow(load).to receive(:valid?)
          }
        end

        context 'with success' do
          let(:success) do
            true
          end

          it 'returns true from Metasploit::Cache::Module::Namespace.transaction block' do
            expect(Metasploit::Cache::Module::Namespace).to receive(:transaction) do |&block|
              expect(block.call(module_ancestor, transaction_namespace_module)).to eq(true)
            end

            namespace_module
          end

          it 'is transaction namespace module' do
            expect(Metasploit::Cache::Module::Namespace).to receive(:transaction) do |&block|
              block.call(module_ancestor, transaction_namespace_module)
            end

            expect(namespace_module).to eq(transaction_namespace_module)
          end
        end

        context 'without success' do
          let(:success) do
            false
          end

          it 'validates the namespace_module' do
            expect(Metasploit::Cache::Module::Namespace).to receive(:transaction) do |&block|
              expect(transaction_namespace_module.load).to receive(:valid?)

              block.call(module_ancestor, transaction_namespace_module)
            end

            namespace_module
          end

          it 'sets @namespace_module_load_errors' do
            expect(Metasploit::Cache::Module::Namespace).to receive(:transaction) do |&block|
              block.call(module_ancestor, transaction_namespace_module)
            end

            expect {
              namespace_module
            }.to change {
                   module_ancestor_load.instance_variable_get :@namespace_module_load_errors
                 }
          end

          it 'returns false from Metapsloit::Cache::Module::Namespace.transaction block' do
            expect(Metasploit::Cache::Module::Namespace).to receive(:transaction) do |&block|
              expect(block.call(module_ancestor, transaction_namespace_module)).to eq(false)
            end

            namespace_module
          end

          it 'should be nil' do
            expect(Metasploit::Cache::Module::Namespace).to receive(:transaction) do |&block|
              block.call(module_ancestor, transaction_namespace_module)
            end

            expect(namespace_module).to be_nil
          end
        end
      end
    end

    context 'without valid for loading' do
      let(:module_ancestor) do
        FactoryGirl.build(:metasploit_cache_module_ancestor, module_type: nil, reference_name: nil, real_path: nil)
      end

      it 'should not be valid for loading' do
        expect(module_ancestor_load).not_to be_valid(:loading)
      end

      it { should be_nil }
    end
  end

  context '#namespace_module_load_errors' do
    subject(:namespace_module_load_errors) do
      module_ancestor_load.namespace_module_load_errors
    end

    context 'with defined' do
      let(:expected_namespace_module_errors) do
        double('ActiveModel::Errors')
      end

      before(:each) do
        module_ancestor_load.instance_variable_set :@namespace_module_load_errors, expected_namespace_module_errors
      end

      it 'should not call #namespace_module' do
        expect(module_ancestor_load).not_to receive(:namespace_module)

        namespace_module_load_errors
      end

      it 'should return already defined namespace_module_load_errors' do
        expect(namespace_module_load_errors).to eq(expected_namespace_module_errors)
      end
    end

    context 'without defined' do
      it 'should call #namespace_module' do
        expect(module_ancestor_load).to receive(:namespace_module)

        namespace_module_load_errors
      end

      context '#namespace_module' do
        before(:each) do
          allow(module_ancestor_load).to receive(:namespace_module).and_return(namespace_module)
        end

        context 'with nil' do
          let(:namespace_module) do
            nil
          end

          it { should be_nil }
        end

        context 'without nil' do
          let(:errors) do
            double('Errors')
          end

          let(:namespace_module) do
            double('Namespace Module', errors: errors)
          end

          it 'should return namespace_modules.errors' do
            expect(namespace_module_load_errors).to eq(errors)
          end
        end
      end
    end
  end

  context 'files', :content do
    # Can't just use the tag on the context because the below code will still run even if tag is filtered out
    if ENV['METASPLOIT_FRAMEWORK_ROOT']
      module_path_real_path = Pathname.new(ENV['METASPLOIT_FRAMEWORK_ROOT']).realpath.join('modules').to_path

      let(:module_path) do
        FactoryGirl.create(
            :mdm_module_path,
            gem: 'metasploit-framework',
            name: 'modules',
            real_path: module_path_real_path
        )
      end

      rule = File::Find.new(
          ftype: 'file',
          pattern: "*#{Metasploit::Model::Module::Ancestor::EXTENSION}",
          path: module_path_real_path
      )

      rule.find { |real_path|
        real_pathname = Pathname.new(real_path)
        relative_pathname = real_pathname.relative_path_from(Metasploit::Framework.root)

        # have context be path relative to project root so context name is consistent no matter where the specs run
        context "#{relative_pathname}" do
          let(:module_ancestor) do
            module_path.module_ancestors.build(real_path: real_path)
          end

          it { should load_metasploit_module }
        end
      }
    end
  end
end