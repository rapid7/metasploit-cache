RSpec.describe Metasploit::Cache::Module::Ancestor::Spec::Unload::Each do
  context 'CONSTANTS' do
    context 'LOG_PATHNAME' do
      subject(:log_pathname) {
        described_class::LOG_PATHNAME
      }

      it { is_expected.to be_a Pathname }
    end
  end

  context 'configure!' do
    subject(:configure!) {
      described_class.configure!
    }

    around(:each) do |example|
      leaks_cleaned_before = Metasploit::Cache::Module::Ancestor::Spec::Unload::Each.leaks_cleaned

      begin
        example.run
      ensure
        Metasploit::Cache::Module::Ancestor::Spec::Unload::Each.leaks_cleaned = leaks_cleaned_before
      end
    end


    before(:each) do
      described_class.instance_variable_set :@configured, false

      expect(described_class.configured?).to eq(false)
    end

    it 'can only be called once' do
      expect(RSpec).to receive(:configure).once

      described_class.configure!
      described_class.configure!
    end

    it 'sets configured?' do
      allow(RSpec).to receive(:configure)

      expect {
        configure!
      }.to change(described_class, :configured?).from(false).to(true)
    end

    context 'RSpec.configure' do
      before(:each) do
        configuration = double('RSpec configuration')

        expect(configuration).to receive(:before) { |timing, &block|
                                   expect(timing).to eq(:each)

                                   @before_each_block = block
                                 }
        expect(configuration).to receive(:after).with(:each) { |&block|
                                     @after_each_block = block
                                 }
        expect(configuration).to receive(:after).with(:suite) { |&block|
                                   @after_suite_block = block
                                 }

        expect(RSpec).to receive(:configure) { |&block|
                           block.call(configuration)
                         }

        configure!
      end

      context 'before(:each)' do
        it 'unloads constants' do
          expect(Metasploit::Cache::Module::Ancestor::Spec::Unload).to receive(:unload).and_return(false)

          @before_each_block.call
        end

        context 'with leaks cleaned' do
          before(:each) do
            expect(Metasploit::Cache::Module::Ancestor::Spec::Unload).to receive(:unload).and_return(true)
          end

          it 'prints full description of example where leak cleaned' do |example|
            message = capture(:stderr) {
              @before_each_block.call(example)
            }

            expect(message).to eq("Cleaned leaked constants before #{example.metadata[:full_description]}\n")
          end

          it 'sets Metasploit::Cache::Module::Ancestor::Spec::Unload::Each.leaks_cleaned' do |example|
            silence(:stderr) {
              @before_each_block.call(example)
            }

            expect(Metasploit::Cache::Module::Ancestor::Spec::Unload::Each.leaks_cleaned).to eq(true)
          end
        end

        context 'without leaks cleaned' do
          before(:each) do
            expect(Metasploit::Cache::Module::Ancestor::Spec::Unload).to receive(:unload).and_return(false)
          end

          it 'does not unset Metasploit::Cache::Module::Ancestor::Spec::Unload::Each.leaks_cleaned' do |example|
            Metasploit::Cache::Module::Ancestor::Spec::Unload::Each.leaks_cleaned = true

            @before_each_block.call(example)

            expect(Metasploit::Cache::Module::Ancestor::Spec::Unload::Each.leaks_cleaned).to eq(true)
          end
        end
      end

      context 'after(:each)' do
        context 'with leaked constants' do
          before(:each) do
            expect(Metasploit::Cache::Module::Ancestor::Spec::Unload).to receive(:each).and_yield('LeakedConstantB').and_yield('LeakedConstantA')
          end

          it 'raises RuntimeError with message containing sorted leaked constant names' do |example|
            expect {
              @after_each_block.call(example)
            }.to raise_error { |error|
                   expect(error).to be_a RuntimeError
                   expect(error.to_s).to eq(
                                             "Leaked constants:\n" \
                                             "  LeakedConstantA\n" \
                                             "  LeakedConstantB\n" \
                                             "\n" \
                                             "Add `include_context 'Metasploit::Cache::Module::Ancestor::Spec::Unload.unload'` to clean up constants from #{example.metadata[:full_description]}"
                                         )
                 }
          end
        end

        context 'without leaked constants' do
          specify { |example|
            expect {
              @after_each_block.call(example)
            }.not_to raise_error
          }
        end
      end

      context 'after(:suite)' do
        #
        # lets
        #

        let(:log_pathname) {
          Pathname.new('log/metasploit/cache/module/ancestor/spec/unload/each.log')
        }

        #
        # Callbacks
        #

        before(:each) do
          Metasploit::Cache::Module::Ancestor::Spec::Unload::Each.leaks_cleaned = leaks_cleaned
        end

        after(:each) do
          if log_pathname.exist?
            log_pathname.delete
          end
        end

        context 'with leaks cleaned' do
          #
          # lets
          #

          let(:leaks_cleaned) {
            true
          }

          #
          # Callbacks
          #

          around(:each) do |example|
            log_content = nil

            if log_pathname.exist?
              log_content = log_pathname.read
            end

            begin
              example.run
            ensure
              if log_content
                log_pathname.open('w') do |f|
                  f.write log_content
                end
              end
            end
          end

          context 'with log/metasploit/cache/module/ancestor/spec/unload/each.log' do
            before(:each) do
              log_pathname.open('w') do |f|
                f.puts "# Spec content"
              end
            end

            it 'deletes the log' do
              expect {
                @after_suite_block.call
              }.to change(log_pathname, :exist?).to(false)
            end
          end

          context 'without log/metasploit/cache/module/ancestor/spec/unload/each.log' do
            before(:each) do
              if log_pathname.exist?
                log_pathname.delete
              end
            end

            it 'does not create the log' do
              expect {
                @after_suite_block.call
              }.not_to change(log_pathname, :exist?).from(false)
            end
          end
        end

        context 'without leaks cleaned' do
          let(:leaks_cleaned) {
            false
          }

          it 'writes instructions to remove Metasploit::Cache::Module::Ancestor::Spec::Unload::Each.configured! from `spec/spec_helper.rb`' do
            @after_suite_block.call

            expect(log_pathname).to exist
            expect(log_pathname.read).to eq(
                                             "No leaks were cleaned by " \
                                             "`Metasploit::Cache::Module::Ancestor::Spec::Unload::Each.configure!`. " \
                                             "Remove it from `spec/spec_helper.rb` so it does not interfere with " \
                                             "contexts that persist loaded modules for entire context and clean up " \
                                             "modules in `after(:all)`\n"
                                         )
          end
        end
      end
    end
  end

  context 'define_task' do
    #
    # lets
    #

    let(:log_pathname) {
      Pathname.new('log/metasploit/cache/module/ancestor/spec/unload/each.log')
    }

    let(:rake_task) do
      double()
    end

    #
    # Callbacks
    #

    around(:each) do |example|
      log_content = nil

      if log_pathname.exist?
        log_content = log_pathname.read
      end

      begin
        example.run
      ensure
        if log_content
          log_pathname.open('w') do |f|
            f.write log_content
          end
        end
      end
    end

    before(:each) do
      stub_const('Rake::Task', rake_task)

      expect(rake_task).to receive(:define_task).with('metasploit:cache:module:ancestor:spec:unload:each:clean') do |&block|
        @metasploit_cache_module_ancestor_spec_unload_each_clean_block = block
      end

      expect(rake_task).to receive(:define_task).with(
                               hash_including(
                                   spec: 'metasploit:cache:module:ancestor:spec:unload:each:clean'
                               )
                           )

      expect(rake_task).to receive(:define_task).with(:spec) do |&block|
        @spec_block = block
      end

      described_class.define_task
    end

    context 'metasploit:cache:module:ancestor:spec:unload:each:clean' do
      context 'with log/metasploit/cache/module/ancestor/spec/unload/each.log' do
        before(:each) do
          log_pathname.open('w') do |f|
            f.puts "# Spec content"
          end
        end

        it 'deletes the log' do
          expect {
            @metasploit_cache_module_ancestor_spec_unload_each_clean_block.call
          }.to change(log_pathname, :exist?).from(true).to(false)
        end
      end

      context 'without log/metasploit/cache/module/ancestor/spec/unload/each.log' do
        before(:each) do
          if log_pathname.exist?
            # :nocov:
            log_pathname.delete
            # :nocov:
          end
        end

        specify {
          expect {
            @metasploit_cache_module_ancestor_spec_unload_each_clean_block.call
          }.not_to raise_error
        }
      end
    end

    context 'spec' do
      context 'with log/metasploit/cache/module/ancestor/spec/unload/each.log' do
        #
        # lets
        #

        let(:expected_log_content) {
          "Line 1\n" \
          "Line 2\n"
        }

        #
        # Callbacks
        #

        before(:each) do
          log_pathname.open('w') do |f|
            f.write expected_log_content
          end
        end

        after(:each) do
          log_pathname.delete
        end

        it 'prints log to stderr before exiting with non-zero status' do
          binding = double()

          expect(binding).to receive(:exit).with(1)

          actual_output = capture(:stderr) {
            binding.instance_eval &@spec_block
          }

          expect(actual_output).to eq(expected_log_content)
        end
      end

      context 'without log/metasploit/cache/module/ancestor/spec/unload/each.log' do
        before(:each) do
          if log_pathname.exist?
            log_pathname.delete
          end
        end

        it 'does not log to stderr or exit' do
          binding = double()

          expect(binding).not_to receive(:exit)

          expect(
              capture(:stderr) {
                binding.instance_eval &@spec_block
              }
          ).to be_empty
        end
      end
    end
  end

  context 'leaks_cleaned?' do
    subject(:leaks_cleaned?) {
      described_class.leaks_cleaned?
    }

    context 'without leaks_cleaned' do
      around(:each) do |example|
        leaks_cleaned_defined = false

        if described_class.instance_variable_defined? :@leaks_cleaned
          # :nocov:
          leaks_cleaned_defined = true
          leaks_cleaned_before = described_class.remove_instance_variable(:@leaks_cleaned)
          # :nocov:
        end

        begin
          example.run
        ensure
          if leaks_cleaned_defined
            # :nocov:
            described_class.leaks_cleaned = leaks_cleaned_before
            # :nocov:
          end
        end
      end

      it { is_expected.to eq(false) }
    end

    context 'with leaks_cleaned' do
      before(:each) do
        described_class.leaks_cleaned = expected_leaks_cleaned
      end

      context 'false' do
        let(:expected_leaks_cleaned) {
          false
        }

        it { is_expected.to eq(expected_leaks_cleaned) }
      end

      context 'true' do
        let(:expected_leaks_cleaned) {
          true
        }

        it { is_expected.to eq(expected_leaks_cleaned) }
      end
    end
  end
end