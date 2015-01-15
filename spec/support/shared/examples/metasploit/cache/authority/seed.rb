shared_examples_for 'Metasploit::Cache::Authority seed' do |attributes={}|
  attributes.assert_valid_keys(:abbreviation, :extension_name, :obsolete, :summary, :url)

  abbreviation = attributes.fetch(:abbreviation)

  context "with #{abbreviation}" do
    subject(:seed) do
      Metasploit::Cache::Authority.where(abbreviation: abbreviation).first
    end

    it 'should exist' do
      expect(seed).not_to be_nil
    end

    obsolete = attributes.fetch(:obsolete)

    it "has obsolete of #{obsolete.inspect}" do
      expect(seed.obsolete).to eq(obsolete)
    end

    summary = attributes.fetch(:summary)

    it "has summary of #{summary.inspect}" do
      expect(seed.summary).to eq(summary)
    end

    url = attributes.fetch(:url)

    it "has url of #{url.inspect}" do
      expect(seed.url).to eq(url)
    end

    extension_name = attributes.fetch(:extension_name)

    if extension_name
      context 'with extension' do
        let(:designation) do
          double('Designation')
        end

        extension = extension_name.constantize

        it "has extension #{extension}" do
          expect(seed.extension).to eq(extension)
        end

        it 'should have extension be a defined class' do
          expect {
            extension
          }.to_not raise_error
        end

        it 'should delegate #designation_url to extension' do
          expect(extension).to receive(:designation_url).with(designation)

          seed.designation_url(designation)
        end
      end
    else
      it 'does not have an extension' do
        expect(seed.extension).to be_nil
      end
    end
  end
end