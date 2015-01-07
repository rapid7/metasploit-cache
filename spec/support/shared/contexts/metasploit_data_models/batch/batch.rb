shared_context 'MetasploitDataModels::Batch.batch' do
  around(:each) do |example|
    Metasploit::Cache::Batch.batch do
      example.run
    end
  end
end