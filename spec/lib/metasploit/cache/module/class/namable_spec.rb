RSpec.describe Metasploit::Cache::Module::Class::Namable do
  context 'CONSTANTS' do
    context 'REFERENCE_NAME_SEPARATOR' do
      subject(:reference_name_separator) do
        described_class::REFERENCE_NAME_SEPARATOR
      end

      it { should == '/' }
    end
  end
end