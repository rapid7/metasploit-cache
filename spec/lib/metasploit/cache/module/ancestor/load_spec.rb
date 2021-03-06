require 'file/find'

RSpec.describe Metasploit::Cache::Module::Ancestor::Load, :cache do
  include_context 'ActiveSupport::TaggedLogging'
  include_context 'Metasploit::Cache::Spec::Unload.unload'

  subject(:module_ancestor_load) do
    described_class.new(
        logger: logger,
        # This should match the major version number of metasploit-framework
        maximum_version: 4,
        module_ancestor: module_ancestor,
        persister_class: Metasploit::Cache::Module::Ancestor::Persister
    )
  end

  let(:module_ancestor) do
    FactoryGirl.create(:metasploit_cache_auxiliary_ancestor)
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
              Module.new
            end

            it 'should not add error on :metasploit_module' do
              expect(module_ancestor_load.errors[:metasploit_module]).not_to include(error)
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

    context '#namespace_module' do
      context 'Metasploit::Cache::Module::Namespace::Load#module_ancestor_eval' do
        #
        # Methods
        #

        def any_namespace_module_errors?
          module_ancestor_load.errors.keys.any? { |key|
            key.to_s.start_with? 'namespace_module.'
          }
        end

        context 'returns true' do
          #
          # Callbacks
          #

          before(:each) do
            module_ancestor_load.valid?
          end

          it 'has no errors on namespace_module.*' do
            expect(any_namespace_module_errors?).to eq false
          end
        end

        context 'returns false' do
          #
          # Callbacks
          #

          before(:each) do
            module_ancestor.real_pathname.open('wb') do |f|
              f.write "fail 'Exception in ancestor'"
            end

            module_ancestor_load.valid?
          end

          it 'has errors on namespace_module.*' do
            expect(any_namespace_module_errors?).to eq true
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
        FactoryGirl.build(
            :metasploit_cache_auxiliary_ancestor,
            content?: false,
            module_type: nil,
            reference_name: nil,
            relative_path: nil
        )
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
    end
  end

  # :nocov:
  # Can't just use the tag on the context because the below code will still run even if tag is filtered out
  unless Bundler.settings.without.include? 'content'
    context 'metasploit-framework', :content do
      module_path_real_paths = Metasploit::Framework::Engine.paths['modules'].existent_directories

      module_path_real_paths.each do |module_path_real_path|
        module_path_real_pathname = Pathname.new(module_path_real_path)
        module_path_relative_pathname = module_path_real_pathname.relative_path_from(Metasploit::Framework::Engine.root)

        # use relative pathname so that context name is not dependent on build directory
        context module_path_relative_pathname.to_s do
          #
          # Shared Examples
          #

          shared_examples_for 'payloads/stagers' do |handler_type_aliased:|
            context 'payloads' do
              context 'stagers' do
                relative_path_prefix = 'payloads/stagers'
                real_prefix_pathname = module_path_real_pathname.join(relative_path_prefix)

                rule = File::Find.new(
                    ftype: 'file',
                    pattern: "*#{Metasploit::Cache::Module::Ancestor::EXTENSION}",
                    path: real_prefix_pathname.to_path
                )

                rule.find do |real_path|
                  real_pathname = Pathname.new(real_path)
                  display_pathname = real_pathname.relative_path_from(real_prefix_pathname)
                  relative_pathname = real_pathname.relative_path_from(module_path_real_pathname)

                  context display_pathname.to_s do
                    let(:payload_stager_ancestor) {
                      module_path.stager_payload_ancestors.build(
                          relative_path: relative_pathname.to_path
                      )
                    }

                    let(:payload_stager_ancestor_load) {
                      Metasploit::Cache::Module::Ancestor::Load.new(
                          logger: logger,
                          maximum_version: 4,
                          module_ancestor: payload_stager_ancestor,
                          persister_class: Metasploit::Cache::Payload::Stager::Ancestor::Persister
                      )
                    }

                    it 'can load with correct Metasploit::Cache::Payload::Stager::Ancestor#handler and Metasploit::Cache::Payload::Stager::Ancestor::Handler#type_alias' do
                      expect(payload_stager_ancestor).to be_valid

                      expect(payload_stager_ancestor_load).to be_valid(:loading)
                      expect(payload_stager_ancestor_load).to be_valid

                      display_path = display_pathname.to_path
                      handler_type_alias = nil

                      if handler_type_aliased.include? display_path
                        handler_type_alias = display_pathname.basename('.rb').to_s
                      end

                      if handler_type_alias
                        expect(payload_stager_ancestor.handler).not_to be_nil
                        expect(payload_stager_ancestor.handler.type_alias).to eq(handler_type_alias)
                      else
                        expect(payload_stager_ancestor.handler).to be_nil
                      end
                    end
                  end
                end
              end
            end
          end

          #
          # lets
          #

          let(:module_path) do
            FactoryGirl.create(
                :metasploit_cache_module_path,
                gem: 'metasploit-framework',
                name: 'modules',
                real_path: module_path_real_path
            )
          end

          include_examples 'payloads/stagers',
                           handler_type_aliased: %w{
                               bsd/x86/bind_ipv6_tcp.rb
                               bsd/x86/reverse_ipv6_tcp.rb
                               linux/x86/bind_ipv6_tcp.rb
                               linux/x86/bind_ipv6_tcp_uuid.rb
                               linux/x86/bind_nonx_tcp.rb
                               linux/x86/bind_tcp_uuid.rb
                               linux/x86/reverse_ipv6_tcp.rb
                               linux/x86/reverse_nonx_tcp.rb
                               linux/x86/reverse_tcp_uuid.rb
                               php/bind_tcp_ipv6.rb
                               php/bind_tcp_ipv6_uuid.rb
                               php/bind_tcp_uuid.rb
                               php/reverse_tcp_uuid.rb
                               python/bind_tcp_uuid.rb
                               python/reverse_tcp_uuid.rb
                               windows/bind_hidden_ipknock_tcp.rb
                               windows/bind_hidden_tcp.rb
                               windows/bind_ipv6_tcp.rb
                               windows/bind_ipv6_tcp_uuid
                               windows/bind_nonx_tcp.rb
                               windows/bind_tcp_rc4.rb
                               windows/bind_ipv6_tcp_uuid.rb
                               windows/bind_tcp_uuid.rb
                               windows/reverse_http_proxy_pstore.rb
                               windows/reverse_ipv6_tcp.rb
                               windows/reverse_nonx_tcp.rb
                               windows/reverse_ord_tcp.rb
                               windows/reverse_tcp_dns.rb
                               windows/reverse_tcp_rc4.rb
                               windows/reverse_tcp_rc4_dns.rb
                               windows/reverse_tcp_uuid.rb
                               windows/reverse_winhttp.rb
                               windows/reverse_winhttps.rb
                               windows/x64/bind_ipv6_tcp.rb
                               windows/x64/bind_ipv6_tcp_uuid.rb
                               windows/x64/bind_tcp_uuid.rb
                               windows/x64/reverse_tcp_uuid.rb
                               windows/x64/reverse_winhttp.rb
                               windows/x64/reverse_winhttps.rb
                           }

          # @note Testing of `relative_path_prefix: auxiliary` has been moved to
          #   spec/lib/metasploit/cache/direct/class/load_spec.rb to eliminate redundant Auxiliary::Ancestor loading.

          # @note Testing of `relative_path_prefix: encoder` has been moved to
          #   spec/lib/metasploit/cache/direct/class/load_spec.rb to eliminate redundant Encoder::Ancestor loading.

          # @note Testing of `relative_path_prefix: exploit` has been moved to
          #   spec/lib/metasploit/cache/direct/class/load_spec.rb to eliminate redundant Exploit::Ancestor loading.

          # @note Testing of `relative_path_prefix: nop` has been moved to
          #   spec/lib/metasploit/cache/direct/class/load_spec.rb to eliminate redundant Nop::Ancestor loading.

          # @note Testing of `relative_path_prefix: post` has been moved to
          #   spec/lib/metasploit/cache/direct/class/load_spec.rb to eliminate redundant Post::Ancestor loading.
        end
      end
    end
  end
  # :nocov:
end