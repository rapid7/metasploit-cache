RSpec.describe Metasploit::Cache::Module::Namespace do
  context 'CONSTANTS' do
    context 'CONTENT' do
      subject(:content) {
        described_class::CONTENT
      }

      it { is_expected.to be_frozen }
      it { is_expected.to include('extend Metasploit::Cache::Module::Namespace::Cacheable') }
      it { is_expected.to include('extend Metasploit::Cache::Module::Namespace::Loadable') }
      it { is_expected.to include('def self.module_eval_with_lexical_scope') }
    end

    context 'CONTENT_FILE' do
      subject(:content_file) {
        described_class::CONTENT_FILE
      }

      let(:root) {
        Pathname.new(__FILE__).parent.parent.parent.parent.parent.parent
      }

      it { is_expected.to eq(root.join('lib', 'metasploit', 'cache', 'module', 'namespace.rb').to_path) }
    end

    context 'CONTENT_LINE' do
      subject(:content_line) {
        described_class::CONTENT_LINE
      }

      it 'is first line of CONTENT in CONTENT_FILE' do
        File.open(described_class::CONTENT_FILE) do |f|
          lines = f.readlines

          # __LINE__ is 1-indexed while array is 0-indexed
          expect(lines[content_line - 1].strip).to eq(described_class::CONTENT.lines[0].strip)
        end
      end
    end

    context 'NAMES' do
      subject(:names) {
        described_class::NAMES
      }

      it "starts with Msf for Metasploit Modules that didn't fully qualify their constants" do
        expect(names).to start_with('Msf')
      end
    end
  end

  context 'create' do
    subject(:create) {
      described_class.create(names)
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

    it 'wraps descendant `module` declaration in ancestor `module` declarations to setup a lexical scope' do
      expect(Object).to receive(:module_eval) { |actual_content|
                          expect(actual_content).to eq(
                                                        <<-EOS.strip_heredoc.strip
                                                          module Grandparent
                                                          module Parent
                                                          module Child
                                                          extend Metasploit::Cache::Module::Namespace::Cacheable
                                                          extend Metasploit::Cache::Module::Namespace::Loadable

                                                          #
                                                          # Module Methods
                                                          #

                                                          # Calls `Module#module_eval` on the `module_ancestor_contents`, but the lexical scope of the namespace_module is
                                                          # passed through module_eval, so that `module_ancestor_contents` can act like it was written inline in the
                                                          # namespace_module.
                                                          #
                                                          # @param module_ancestor_contents [String] {Metasploit::Cache::Module::Ancestor#contents}
                                                          # @param module_ancestor_real_path [String] The path to the `Module`, so that error messages in evaluating
                                                          #   `module_ancestor_contents` can be reported correctly.
                                                          def self.module_eval_with_lexical_scope(module_ancestor_contents, module_ancestor_real_path)
                                                            # By calling module_eval from inside the module definition, the lexical scope is captured and available to the
                                                            # code in `module_ancestor_contents`.
                                                            module_eval(module_ancestor_contents, module_ancestor_real_path)
                                                          end

                                                          end
                                                          end
                                                          end
                                                        EOS
                                                    )
                        }

      create
    end

    it 'sets path for Object.module_eval' do
      expect(Object).to receive(:module_eval).with(anything, described_class::CONTENT_FILE, anything)

      create
    end

    it 'sets line for Object.module_eval' do
      expect(Object).to receive(:module_eval).with(anything, anything, 18)

      create
    end

    it 'sets path and line so that backtrace appears in CONTENT' do
      namespace_module = create

      module_ancestor = FactoryGirl.build(:metasploit_cache_auxiliary_ancestor)

      module_ancestor.real_pathname.open('w') do |f|
        f.puts 'raise "Error in module_eval_with_lexical_scope"'
      end

      module_ancestor_real_path = module_ancestor.real_pathname.to_path

      expect {
        namespace_module.module_eval_with_lexical_scope(module_ancestor.contents, module_ancestor_real_path)
      }.to raise_error(RuntimeError) { |error|
             backtrace = error.backtrace

             expect(backtrace[0]).to start_with(module_ancestor_real_path)
             expect(backtrace[1]).to match(/#{Regexp.escape(described_class::CONTENT_FILE)}:\d+:in `module_eval'/)

             path, line, code = backtrace[2].split(':')
             expect(path).to eq(described_class::CONTENT_FILE)
             expect(line.to_i).to eq(described_class::CONTENT_LINE + 17)
             expect(code).to match(/module_eval_with_lexical_scope/)
           }
    end
  end

  context 'names' do
    subject(:names) {
      described_class.names(module_ancestor)
    }

    let(:module_ancestor) {
      FactoryGirl.build(:metasploit_cache_auxiliary_ancestor).tap { |module_ancestor|
        # validate to populate #real_path_sha1_hex_digest
        module_ancestor.valid?
      }
    }

    it 'starts with NAMES' do
      expect(names).to start_with(described_class::NAMES)
    end

    it 'contains Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest' do
      expect(
          names.any? { |part|
            part.include?(module_ancestor.real_path_sha1_hex_digest)
          }
      ).to eq(true)
    end
  end

  context 'transaction' do
    include_context 'Metasploit::Cache::Spec::Unload.unload'

    #
    # Methods
    #

    def current
      Metasploit::Cache::Constant.current(described_class.names(module_ancestor))
    end

    def transaction(&block)
      described_class.transaction(module_ancestor, &block)
    end

    #
    # lets
    #

    let(:module_ancestor) {
      FactoryGirl.build(:metasploit_cache_auxiliary_ancestor)
    }

    context 'with previous namespace module' do
      #
      # lets
      #

      let(:previous_namespace_module) {
        current
      }

      #
      # Callbacks
      #

      before(:each) do
        transaction { |module_ancestor, namespace_module|
          namespace_module.define_singleton_method(:version) {
            1
          }

          true
        }

        # ensure previous namespace module is captured after creating transaction, but before any test code
        expect(previous_namespace_module.version).to eq(1)
      end

      it 'passes new namespace module to block' do
        block_ran = false

        transaction { |block_module_ancestor, namespace_module|
          expect(block_module_ancestor).to eq(module_ancestor)

          expect(namespace_module).not_to eq(previous_namespace_module)
          expect(namespace_module).to be_a Module
          expect(namespace_module.name).to start_with('Msf::')
          expect(namespace_module.name.split('::')).to eq(described_class.names(module_ancestor))

          block_ran = true
        }

        expect(block_ran).to eq(true)
      end

      it 'sets module_type on namespace module passed to block' do
        block_ran = false

        expect(module_ancestor.module_type).not_to be_nil

        transaction { |_, namespace_module|
          expect(namespace_module.cache.module_type).to eq(module_ancestor.module_type)

          block_ran = true
        }

        expect(block_ran).to eq(true)
      end

      it 'sets real_path_sha1_hex_digest on namespace module passed to block' do
        block_ran = false

        # validate to populate real_path_sha1_hex_digest
        module_ancestor.valid?

        expect(module_ancestor.real_path_sha1_hex_digest).not_to be_nil

        transaction { |_, namespace_module|
          expect(namespace_module.cache.real_path_sha1_hex_digest).to eq(module_ancestor.real_path_sha1_hex_digest)

          block_ran = true
        }

        expect(block_ran).to eq(true)
      end

      context 'with Exception' do
        let(:exception) {
          Exception.new("error message")
        }

        it 'raises exception' do
          expect {
            transaction {
              raise exception
            }
          }.to raise_error(exception)
        end

        it 'restores previous namespace module' do
          expect {
            transaction {
              expect(current).not_to eq(previous_namespace_module)

              raise exception
            }
          }.to raise_error(exception)

          expect(current).to eq(previous_namespace_module)
        end
      end

      context 'without Exception' do
        context 'with commit' do
          let(:commit) {
            true
          }

          it 'leaves new namespace module in place' do
            new_namespace_module = nil

            transaction { |_, block_new_namespace_module|
              new_namespace_module = block_new_namespace_module

              commit
            }

            expect(current).not_to be_nil
            expect(current).to eq(new_namespace_module)
          end

          it 'returns commit' do
            expect(
                transaction {
                  commit
                }
            ).to eq(commit)
          end
        end

        context 'without commit' do
          let(:commit) {
            false
          }

          it 'restores previous namespace module' do
            transaction {
              expect(current).not_to eq(previous_namespace_module)

              commit
            }

            expect(current).to eq(previous_namespace_module)
          end

          it 'returns commit' do
            expect(
                transaction {
                  commit
                }
            ).to eq(commit)
          end
        end
      end
    end

    context 'without namespace module' do
      it 'passes module_ancestor and new namespace module to block' do
        block_ran = false

        transaction { |block_module_ancestor, namespace_module|
          expect(block_module_ancestor).to eq(module_ancestor)

          expect(namespace_module).to be_a Module
          expect(namespace_module.name).to start_with('Msf::')
          expect(namespace_module.name.split('::')).to eq(described_class.names(module_ancestor))

          block_ran = true
        }

        expect(block_ran).to eq(true)
      end

      it 'sets cache.module_type on namespace module passed to block' do
        block_ran = false

        expect(module_ancestor.module_type).not_to be_nil

        transaction { |_, namespace_module|
          expect(namespace_module.cache.module_type).to eq(module_ancestor.module_type)

          block_ran = true
        }

        expect(block_ran).to eq(true)
      end

      it 'sets real_path_sha1_hex_digest on namespace module passed to block' do
        block_ran = false

        # validate to populate real_path_sha1_hex_digest
        module_ancestor.valid?

        expect(module_ancestor.real_path_sha1_hex_digest).not_to be_nil

        transaction { |_, namespace_module|
          expect(namespace_module.cache.real_path_sha1_hex_digest).to eq(module_ancestor.real_path_sha1_hex_digest)

          block_ran = true
        }

        expect(block_ran).to eq(true)
      end

      context 'with Exception' do
        let(:exception) {
          Exception.new("error message")
        }

        it 'raises exception' do
          expect {
            transaction {
              raise exception
            }
          }.to raise_error(exception)
        end

        it 'undefines namespace module constant' do
          expect {
            transaction {
              expect(current).not_to be_nil

              raise exception
            }
          }.to raise_error(exception)

          expect(current).to be_nil
        end
      end

      context 'without Exception' do
        context 'with commit' do
          let(:commit) {
            true
          }

          it 'leaves new namespace module in place' do
            expect {
                transaction {
                  commit
                }
            }.to change { current }
          end

          it 'returns commit' do
            expect(
                transaction {
                  commit
                }
            ).to eq(commit)
          end
        end

        context 'without commit' do
          let(:commit) {
            false
          }

          it 'undefines namespace module constant' do
            transaction {
              expect(current).not_to be_nil

              commit
            }

            expect(current).to be_nil
          end

          it 'returns commit' do
            expect(
                transaction {
                  commit
                }
            ).to eq(commit)
          end
        end
      end
    end
  end
end