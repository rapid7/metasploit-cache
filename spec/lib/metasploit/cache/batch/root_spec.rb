require 'spec_helper'

RSpec.describe Metasploit::Cache::Batch::Root do
  subject(:base_instance) do
    base_class.new
  end

  let(:base_class) do
    described_class = self.described_class

    Class.new do
      include described_class

      def save

      end
    end
  end

  it_should_behave_like 'MetasploitDataModels::Batch::Root'
end