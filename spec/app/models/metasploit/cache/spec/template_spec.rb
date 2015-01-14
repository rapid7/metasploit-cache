RSpec.describe Metasploit::Cache::Spec::Template do
  subject(:template) {
    FactoryGirl.build(:metasploit_cache_spec_template)
  }

  context 'CONSTANTS' do
    context 'BACKTRACE_FILE_REGEXP' do
      subject(:backtrace_file_regexp) {
        described_class::BACKTRACE_FILE_REGEXP
      }

      it 'extracts file from line of backtrace' do
        match = backtrace_file_regexp.match(caller[0])

        expect(match).not_to be_nil
        expect(match[:file]).to end_with('/lib/rspec/core/example.rb')
      end
    end

    context 'EXPLICIT_TRIM_MODE' do
      subject(:explicit_trim_mode) {
        described_class::EXPLICIT_TRIM_MODE
      }

      it { is_expected.to eq('-') }
    end

    context 'EXTENSION' do
      subject(:extension) {
        described_class::EXTENSION
      }

      it { is_expected.to eq('.rb.erb') }
    end
  end

  context 'factories' do
    context 'metasploit_cache_spec_template' do
      subject(:metasploit_cache_spec_template) {
        FactoryGirl.build(:metasploit_cache_spec_template)
      }

      it { is_expected.to be_valid }
    end
  end

  context '.render_super' do
    subject(:render_super) {
      template.render_super
    }

    context 'with unknown caller format' do
      #
      # lets
      #

      let(:backtrace) {
        [
            'unknown format'
        ]
      }

      #
      # Callbacks
      #

      before(:each) do
        expect(template).to receive(:caller).and_return(backtrace)
      end

      specify {
        expect {
          render_super
        }.to raise_error(RegexpError, "Can't parse file from backtrace to determine current search path")
      }
    end

    context 'with known caller format' do
      context 'without super template' do
        specify {
          expect {
            render_super
          }.to raise_error(IOError, "Couldn't find super template")
        }
      end
    end
  end

  context '.root' do
    around(:each) do |example|
      old_root = described_class.root

      begin
        example.run
      ensure
        described_class.root = old_root
      end
    end

    it 'modifies subclass root when set' do
      expected = double('root')

      expect {
        described_class.root = expected
      }.to change(Metasploit::Cache::Module::Ancestor::Spec::Template, :root).to(expected)
    end
  end
end