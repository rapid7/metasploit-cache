shared_context 'Metasploit::Cache::Batch.batch' do
  around(:each) do |example|
    Metasploit::Cache::Batch.batch do
      example.run
    end
  end
end