shared_examples_for 'Metasploit::Cache::Architecture seed' do |attributes={}|
  attributes.assert_valid_keys(:abbreviation, :bits, :endianness, :family, :summary)

  context_abbreviation = attributes.fetch(:abbreviation)

  context "with #{context_abbreviation}" do
    subject(:seed) do
      described_class.where(abbreviation: abbreviation).first
    end

    # put in a let so that `let(:seed)` has access to abbreviation.
    let(:abbreviation) do
      context_abbreviation
    end

    it 'should exist' do
      expect(seed).not_to be_nil
    end

    bits = attributes.fetch(:bits)

    it "has #{bits.inspect} bits" do
      expect(seed.bits).to eq(bits)
    end

    endianness = attributes.fetch(:endianness)

    it "has #{endianness.inspect} endianness" do
      expect(seed.endianness).to eq(endianness)
    end

    family = attributes.fetch(:family)

    it "is member of the #{family.inspect} family" do
      expect(seed.family).to eq(family)
    end

    summary = attributes.fetch(:summary)

    it "has summary of '#{summary}'" do
      expect(seed.summary).to eq(summary)
    end
  end
end