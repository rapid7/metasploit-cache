RSpec.describe Metasploit::Cache::Module::Ancestor::Spec::Unload::Suite do
  context 'CONSTANTS' do
    context 'LOGS_PATHNAME' do
      subject(:logs_pathname) {
        described_class::LOGS_PATHNAME
      }

      it { is_expected.to eq(Pathname.new('log/metasploit/cache/module/ancestor/spec/unload/suite')) }
    end
  end

  context 'configure!' do
    subject(:configure!) {
      described_class.configure!
    }

    around(:each) do |example|
      defined_before = false
      configured_before = nil

      if described_class.instance_variable_defined? :@configured
        defined_before = true
        configured_before = described_class.remove_instance_variable :@configured
      end

      begin
        example.run
      ensure
        if defined_before
          described_class.instance_variable_set :@configured, configured_before
        end
      end
    end

    context 'with configured' do
      before(:each) do
        described_class.instance_variable_set :@configured, true
      end

      it 'does not reconfigure RSpec' do
        expect(RSpec).not_to receive(:configure)

        configure!
      end
    end

    context 'without configured' do
      before(:each) do
        described_class.instance_variable_set :@configured, false

        expect(RSpec).to receive(:configure) { |&configure_block|
                           configuration = double()

                           expect(configuration).to receive(:before).with(:suite) { |&block|
                                                      @before_suite_block = block
                                                    }

                           expect(configuration).to receive(:after).with(:suite) { |&block|
                                                      @after_suite_block = block
                                                    }

                           configure_block.call(configuration)
                         }

        configure!
      end

      context 'before(:suite)' do
        it 'logs constants leaked before suite starts' do
          expect(described_class).to receive(:log_leaked_constants).with(
                                         :before,
                                         'Modules are being loaded outside callbacks before suite starts.'
                                     )

          @before_suite_block.call
        end
      end

      context 'after(:suite)' do
        it 'logs constants leaked after suite has run' do
          expect(described_class).to receive(:log_leaked_constants).with(
                                         :after,
                                         'Modules are being loaded inside callbacks or examples during suite run.'
                                     )

          @after_suite_block.call
        end
      end
    end
  end

  context 'define_task' do
    subject(:define_task) {
      described_class.define_task
    }

    before(:each) do
      rake_task = double()

      stub_const('Rake::Task', rake_task)

      expect(rake_task).to receive(:define_task).with(:spec) do |&block|
        @spec_block = block
      end

      define_task

      expect(described_class).to receive(:print_leaked_constants).with(:before).and_return(leaked_before)
      expect(described_class).to receive(:print_leaked_constants).with(:after).and_return(leaked_after)
    end

    context 'with leaks before' do
      let(:leaked_after) {
        false
      }

      let(:leaked_before) {
        true
      }

      it 'exits with 1' do
        expect {
          @spec_block.call
        }.to raise_error(SystemExit) { |error|
               expect(error.status).to eq(1)
             }
      end
    end

    context 'with leaks after' do
      let(:leaked_after) {
        true
      }

      let(:leaked_before) {
        false
      }

      it 'prints instructions to stderr for adding Metasploit::Cache::Module::Ancestor::Spec::Unload::Each.configure! to `spec/spec_helper.rb`' do
        binding = double

        allow(binding).to receive(:exit)

        stderr = capture(:stderr) {
          binding.instance_eval &@spec_block
        }

        expect(stderr).to eq(
                              "\n" \
                              "Add `Metasploit::Cache::Module::Ancestor::Spec::Unload::Each.configure!` to " \
                              "`spec/spec_helper.rb` **NOTE: " \
                              "`Metasploit::Cache::Module::Ancestor::Spec::Unload::Each` may report false leaks if " \
                              "`after(:all)` is used to clean up constants instead of `after(:each)`**\n"
                          )
      end

      it 'exits with 1' do
        expect {
          @spec_block.call
        }.to raise_error(SystemExit) { |error|
               expect(error.status).to eq(1)
             }
      end
    end

    context 'without leaks' do
      let(:leaked_after) {
        false
      }

      let(:leaked_before) {
        false
      }

      it 'does not exit' do
        expect {
          @spec_block.call
        }.not_to raise_error
      end
    end
  end

  context 'log_leaked_constants' do
    subject(:log_leaked_constants) do
      described_class.log_leaked_constants(hook, message)
    end

    #
    # lets
    #

    let(:hook) {
      # a non-existent hook
      'parallel'
    }

    let(:log_pathname) {
      Pathname.new("log/metasploit/cache/module/ancestor/spec/unload/suite/#{hook}.log")
    }

    let(:message) {
      "Things are happening."
    }

    #
    # Callbacks
    #

    around(:each) do |example|
      log_content_before = nil

      if log_pathname.exist?
        log_content_before = log_pathname.read
      end

      begin
        example.run
      ensure
        if log_content_before
          log_pathname.open('w') do |f|
            f.write log_content_before
          end
        end
      end
    end

    after(:each) do
      if log_pathname.exist?
        log_pathname.delete
      end
    end

    context 'with leaks' do
      before(:each) do
        stub_const('Msf::Modules::FirstLeakedConstant', Module.new)
        stub_const('Msf::Modules::SecondLeakedConstant', Module.new)
      end

      it 'prints leaked constants to hook log' do
        log_leaked_constants

        expect(log_pathname.read).to eq(
                                         "FirstLeakedConstant\n" \
                                         "SecondLeakedConstant\n"
                                     )
      end

      it 'prints warning about leaks to stderr' do
        stderr = capture(:stderr) {
          log_leaked_constants
        }

        expect(stderr).to eq("2 constants leaked under Msf::Modules. #{message} See #{log_pathname} for details.\n")
      end
    end

    context 'without leaks' do
      it 'does not leave a hook log' do
        log_leaked_constants

        expect(log_pathname).not_to exist
      end
    end
  end

  context 'log_pathanme' do
    subject(:log_pathname) {
      described_class.log_pathname(hook)
    }

    let(:hook) {
      'spec'
    }

    it 'is under LOGS_PATHNAME' do
      expect(log_pathname.relative_path_from(described_class::LOGS_PATHNAME).to_path).not_to include('..')
    end

    it 'ends in .log' do
      expect(log_pathname.extname).to eq('.log')
    end

    it 'uses hook for name' do
      expect(log_pathname.basename.to_path).to eq("#{hook}.log")
    end
  end

  context 'print_leaked_constants' do
    subject(:print_leaked_constants) {
      described_class.print_leaked_constants(hook)
    }

    #
    # lets
    #

    let(:hook) {
      :spec
    }

    let(:log_pathname) {
      Pathname.new("log/metasploit/cache/module/ancestor/spec/unload/suite/#{hook}.log")
    }

    #
    # Callbacks
    #

    after(:each) do
      if log_pathname.exist?
        log_pathname.delete
      end
    end

    context 'with log' do
      before(:each) do
        log_pathname.open('w') do |f|
          f.puts "FirstLeakedConstant"
          f.puts "SecondLeakedConstant"
        end

        stub_const('Msf::Modules', Module.new)
      end

      it 'indented leaked constants under explanation of their origin' do
        expect(
            capture(:stderr) {
              print_leaked_constants
            }
        ).to eq(
                 "Leaked constants detected under Msf::Modules spec suite:\n" \
                 "  FirstLeakedConstant\n" \
                 "  SecondLeakedConstant\n"
               )
      end

      it { is_expected.to eq(true) }
    end

    context 'without log' do
      before(:each) do
        if log_pathname.exist?
          # :nocov:
          log_pathname.delete
          # :nocov:
        end
      end

      it 'prints nothing to stderr' do
        expect(
            capture(:stderr) {
              print_leaked_constants
            }
        ).to be_empty
      end

      it { is_expected.to eq(false) }
    end
  end
end