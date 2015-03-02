RSpec.describe Metasploit::Cache::Module::Namespace::Load do
  subject(:module_namespace_load) {
    described_class.new(
        logger: logger,
        maximum_api_version: maximum_api_version,
        maximum_core_version: maximum_core_version,
        maximum_version: maximum_version,
        module_namespace: module_namespace
    )
  }

  let(:logger) {
    ActiveSupport::TaggedLogging.new(
        Logger.new(log_string_io)
    )
  }

  let(:log_string_io) {
    StringIO.new
  }

  let(:maximum_api_version) {
    1
  }

  let(:maximum_core_version) {
    4
  }

  let(:maximum_version) {
    4
  }

  let(:module_namespace) {
    Module.new do
      def self.module_eval_with_lexical_scope(contents, real_path)
        module_eval(contents, real_path, 1)
      end
    end
  }

  context 'validations' do
    context '#module_ancestor_eval_valid' do
      #
      # lets
      #

      let(:module_ancestor_eval_errors) {
        module_namespace_load.valid?

        module_namespace_load.errors[:module_ancestor_eval]
      }

      #
      # Callbacks
      #

      before(:each) {
        module_namespace_load.instance_variable_set(:@module_ancestor_eval_exception, module_ancestor_eval_exception)
      }

      context 'with #module_ancestor_eval_exception' do
        let(:module_ancestor_eval_exception) {
          Exception.new("error message").tap { |exception|
            exception.set_backtrace(
                [
                    "line 1",
                    "line 2"
                ]
            )
          }
        }

        it 'adds error' do
          expect(module_ancestor_eval_errors).to include(
                                                     "Exception error message:\n" \
                                                     "line 1\n" \
                                                     "line 2"
                                                 )
        end
      end

      context 'without #module_ancestor_eval_exception' do
        let(:module_ancestor_eval_exception) {
          nil
        }

        it 'does not add error' do
          expect(module_ancestor_eval_errors).to be_empty
        end
      end
    end

    context '#metasploit_module_usable' do
      #
      # lets
      #

      let(:error) {
        I18n.translate!('metasploit.model.errors.models.metasploit/cache/module/namespace/load.attributes.metasploit_module.unusable')
      }

      let(:metasploit_module_errors) {
        module_namespace_load.valid?

        module_namespace_load.errors[:metasploit_module]
      }

      #
      # Callbacks
      #

      before(:each) do
        allow(module_namespace_load).to receive(:metasploit_module).and_return(metasploit_module)
      end

      context 'with #metasploit_module' do
        let(:metasploit_module) {
          Module.new
        }

        context 'that responds to #is_usable' do
          before(:each) do
            usable = self.usable

            metasploit_module.define_singleton_method(:is_usable) do
              usable
            end
          end

          context 'with true' do
            let(:usable) {
              true
            }

            it 'does not add error' do
              expect(metasploit_module_errors).not_to include(error)
            end
          end

          context 'with false' do
            let(:usable) {
              false
            }

            it 'adds error' do
              expect(metasploit_module_errors).to include(error)
            end
          end
        end

        context 'with does not respond to #is_usable' do
          it 'does not add error' do
            expect(metasploit_module_errors).not_to include(error)
          end
        end
      end

      context 'without #metasploit_module' do
        let(:metasploit_module) {
          nil
        }

        it 'does not add error' do
          expect(metasploit_module_errors).not_to include(error)
        end
      end
    end

    context 'on #metasploit_module' do
      let(:error) {
        I18n.translate('errors.messages.blank')
      }

      let(:metasploit_module_errors) {
        module_namespace_load.valid?

        module_namespace_load.errors[:metasploit_module]
      }

      context 'with nil' do
        it 'adds error' do
          expect(metasploit_module_errors).to include(error)
        end
      end

      context 'without nil' do
        #
        # lets
        #

        let(:module_ancestor) {
          FactoryGirl.build(:metasploit_cache_module_ancestor)
        }

        #
        # Callbacks
        #

        before(:each) do
          module_namespace_load.module_ancestor_eval(module_ancestor)
        end

        it 'does not add error' do
          expect(metasploit_module_errors).not_to include(error)
        end
      end
    end

    context 'on #minimum_api_version' do
      let(:minimum_api_version_errors) {
        module_namespace_load.valid?

        module_namespace_load.errors[:minimum_api_version]
      }

      context 'with nil' do
        it 'does not add error' do
          expect(minimum_api_version_errors).to be_empty
        end
      end

      context 'without nil' do
        #
        # lets
        #

        let(:maximum_api_version) {
          1
        }

        let(:minimum_core_version) {
          4
        }

        let(:module_ancestor) {
          FactoryGirl.build(:metasploit_cache_module_ancestor)
        }

        #
        # Callbacks
        #

        before(:each) do
          File.open(module_ancestor.real_path, 'w') do |f|
            f.puts "RequiredVersions = [#{minimum_core_version}, #{minimum_api_version}]"
            f.puts ""
            f.puts "module Metasploit4"
            f.puts "  def self.is_usable"
            f.puts "    true"
            f.puts "  end"
            f.puts "end"
          end

          module_namespace_load.module_ancestor_eval(module_ancestor)
        end

        context 'equal to #maximum_api_version' do
          let(:minimum_api_version) {
            maximum_api_version
          }

          it 'does not add error' do
            expect(minimum_api_version_errors).to be_empty
          end
        end

        context 'greater than #maximum_api_version' do
          let(:error) {
            I18n.translate('errors.messages.less_than_or_equal_to', count: maximum_api_version)
          }

          let(:minimum_api_version) {
            maximum_api_version + 1
          }

          it 'adds error' do
            expect(minimum_api_version_errors).to include(error)
          end
        end
      end
    end

    context 'on #minimum_core_version' do
      let(:minimum_core_version_errors) {
        module_namespace_load.valid?

        module_namespace_load.errors[:minimum_core_version]
      }

      context 'with nil' do
        it 'does not add error' do
          expect(minimum_core_version_errors).to be_empty
        end
      end

      context 'without nil' do
        #
        # lets
        #

        let(:minimum_api_version) {
          1
        }

        let(:maximum_core_version) {
          4
        }

        let(:module_ancestor) {
          FactoryGirl.build(:metasploit_cache_module_ancestor)
        }

        #
        # Callbacks
        #

        before(:each) do
          File.open(module_ancestor.real_path, 'w') do |f|
            f.puts "RequiredVersions = [#{minimum_core_version}, #{minimum_api_version}]"
            f.puts ""
            f.puts "module Metasploit4"
            f.puts "  def self.is_usable"
            f.puts "    true"
            f.puts "  end"
            f.puts "end"
          end

          module_namespace_load.module_ancestor_eval(module_ancestor)
        end

        context 'equal to #maximum_core_version' do
          let(:minimum_core_version) {
            maximum_core_version
          }

          it 'does not add error' do
            expect(minimum_core_version_errors).to be_empty
          end
        end

        context 'greater than #maximum_core_version' do
          let(:error) {
            I18n.translate('errors.messages.less_than_or_equal_to', count: maximum_core_version)
          }

          let(:minimum_core_version) {
            maximum_core_version + 1
          }

          it 'adds error' do
            expect(minimum_core_version_errors).to include(error)
          end
        end
      end
    end
  end

  context '#metasploit_module' do
    subject(:metasploit_module) {
      module_namespace_load.metasploit_module
    }

    context 'before #module_ancestor_eval' do
      it { is_expected.to be_nil }
    end

    context 'after #module_ancestor_eval' do
      let(:module_ancestor) {
        FactoryGirl.build(:metasploit_cache_module_ancestor)
      }

      context 'with constant matching Metasploit<n>' do
        context 'without Module' do
          before(:each) do
            File.open(module_ancestor.real_path, 'w') do |f|
              f.puts "Metasploit#{n} = nil"
            end

            module_namespace_load.module_ancestor_eval(module_ancestor)
          end

          context 'with 0' do
            let(:n) {
              0
            }

            it { is_expected.to be_nil }
          end

          context 'with 1' do
            let(:n) {
              1
            }

            it { is_expected.to be_nil }
          end

          context 'with #maximum_version' do
            let(:n) {
              maximum_version
            }

            it { is_expected.to be_nil }
          end

          context 'with > #maximum_version' do
            let(:n) {
              maximum_version + 1
            }

            it { is_expected.to be_nil }
          end
        end

        context 'with Module' do
          before(:each) do
            File.open(module_ancestor.real_path, 'w') do |f|
              f.puts "module Metasploit#{n}"
              f.puts "end"
            end

            module_namespace_load.module_ancestor_eval(module_ancestor)
          end

          context 'with 0' do
            let(:n) {
              0
            }

            it { is_expected.to be_nil }
          end

          context 'with 1' do
            let(:n) {
              1
            }

            it 'is the Module' do
              expect(metasploit_module).to eq(module_namespace.const_get("Metasploit#{n}"))
            end

            it 'extends Metasploit::Cache::Module::Ancestor::Cacheable' do
              expect(metasploit_module).to be_a Metasploit::Cache::Module::Ancestor::Cacheable
            end
          end

          context 'with #maximum_version' do
            let(:n) {
              maximum_version
            }

            it 'is the Module' do
              expect(metasploit_module).to eq(module_namespace.const_get("Metasploit#{n}"))
            end

            it 'extends Metasploit::Cache::Module::Ancestor::Cacheable' do
              expect(metasploit_module).to be_a Metasploit::Cache::Module::Ancestor::Cacheable
            end
          end

          context 'with > #maximum_version' do
            let(:n) {
              maximum_version + 1
            }

            it { is_expected.to be_nil }
          end
        end

        context 'with Class' do
          before(:each) do
            File.open(module_ancestor.real_path, 'w') do |f|
              f.puts "class Metasploit#{n}"
              f.puts "end"
            end

            module_namespace_load.module_ancestor_eval(module_ancestor)
          end

          context 'with 0' do
            let(:n) {
              0
            }

            it { is_expected.to be_nil }
          end

          context 'with 1' do
            let(:n) {
              1
            }

            it 'is the class' do
              expect(metasploit_module).to eq(module_namespace.const_get("Metasploit#{n}"))
            end

            it 'extends Metasploit::Cache::Module::Ancestor::Cacheable' do
              expect(metasploit_module).to be_a Metasploit::Cache::Module::Ancestor::Cacheable
            end
          end

          context 'with #maximum_version' do
            let(:n) {
              maximum_version
            }

            it 'is the class' do
              expect(metasploit_module).to eq(module_namespace.const_get("Metasploit#{n}"))
            end

            it 'extends Metasploit::Cache::Module::Ancestor::Cacheable' do
              expect(metasploit_module).to be_a Metasploit::Cache::Module::Ancestor::Cacheable
            end
          end

          context 'with > #maximum_version' do
            let(:n) {
              maximum_version + 1
            }

            it { is_expected.to be_nil }
          end
        end
      end

      context 'without constant matching Metasploit<n>' do
        before(:each) do
          File.open(module_ancestor.real_path, 'w') do |f|
            f.puts "# This space intentionally left blank"
          end

          module_namespace_load.module_ancestor_eval(module_ancestor)
        end

        it { is_expected.to be_nil }
      end
    end
  end

  context '#minimum_api_version' do
    subject(:minimum_api_version) {
      module_namespace_load.minimum_api_version
    }

    context 'with RequiredVersions' do
      let(:expected_minimum_api_version) {
        1
      }

      let(:expected_minimum_core_version) {
        2
      }

      #
      # Callbacks
      #

      before(:each) do
        module_namespace::RequiredVersions = [expected_minimum_core_version, expected_minimum_api_version]
      end

      it 'is second element of RequiredVersions' do
        expect(minimum_api_version).to eq(expected_minimum_api_version)
      end
    end

    context 'without RequiredVersions' do
      it { is_expected.to be_nil }
    end
  end

  context '#minimum_core_version' do
    subject(:minimum_core_version) {
      module_namespace_load.minimum_core_version
    }

    context 'with RequiredVersions' do
      let(:expected_minimum_api_version) {
        1
      }

      let(:expected_minimum_core_version) {
        2
      }

      #
      # Callbacks
      #

      before(:each) do
        module_namespace::RequiredVersions = [expected_minimum_core_version, expected_minimum_api_version]
      end

      it 'is first element of RequiredVersions' do
        expect(minimum_core_version).to eq(expected_minimum_core_version)
      end
    end

    context 'without RequiredVersions' do
      it { is_expected.to be_nil }
    end
  end

  context '#module_ancestor_eval' do
    subject(:module_ancestor_eval) {
      module_namespace_load.module_ancestor_eval(module_ancestor)
    }

    let(:module_ancestor) {
      FactoryGirl.build(:metasploit_cache_module_ancestor)
    }

    context 'with Interrupt' do
      before(:each) do
        expect(module_namespace).to receive(:module_eval_with_lexical_scope).and_raise(Interrupt)
      end

      specify {
        expect {
          module_ancestor_eval
        }.to raise_error(Interrupt)
      }
    end

    context 'with Exception' do
      #
      # lets
      #

      let(:exception) {
        Exception.new("error message")
      }

      #
      # Callbacks
      #

      before(:each) do
        expect(module_namespace).to receive(:module_eval_with_lexical_scope).and_raise(exception)
      end

      specify {
        expect {
          module_ancestor_eval
        }.not_to raise_error
      }

      it 'records Exception in #module_ancestor_eval_exception' do
        expect {
        module_ancestor_eval
        }.to change(module_namespace_load, :module_ancestor_eval_exception).from(nil).to(exception)
      end

      it { is_expected.to eq(false) }
    end

    context 'without Exception' do
      context 'with valid' do
        context 'with persisted' do
          it { is_expected.to eq(true) }

          specify {
            expect {
              module_ancestor_eval
            }.to change(Metasploit::Cache::Module::Ancestor, :count).by(1)
          }
        end

        context 'without persisted' do
          before(:each) do
            expect(module_ancestor).to receive(:batched_save).and_return(false)
          end

          it { is_expected.to eq(false) }

          it 'logs to #logger' do
            module_ancestor_eval

            expect(log_string_io.string).not_to be_empty
          end
        end
      end

      context 'without valid' do
        before(:each) do
          File.open(module_ancestor.real_path, 'w') do |f|
            f.puts "module Metasploit4"
            f.puts "  def self.is_usable"
            f.puts "    false"
            f.puts "  end"
            f.puts "end"
          end
        end

        it { is_expected.to eq(false) }
      end
    end
  end

  context '#required_versions' do
    subject(:required_versions) {
      module_namespace_load.required_versions
    }

    #
    # lets
    #

    let(:module_namespace) {
      Module.new
    }

    #
    # Callbacks
    #

    before(:each) do
      allow(module_namespace_load).to receive(:module_namespace).and_return(module_namespace)
    end

    context 'with RequiredVersions' do
      #
      # lets
      #

      let(:expected_required_versions) {
        [1, 2]
      }

      #
      # Callbacks
      #

      before(:each) do
        module_namespace::RequiredVersions = expected_required_versions
      end

      it 'is RequiredVersions' do
        expect(required_versions).to eq(expected_required_versions)
      end
    end

    context 'without RequiredVersions' do
      it { is_expected.to eq([nil, nil]) }
    end
  end
end