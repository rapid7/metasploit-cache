shared_context '$LOAD_PATH' do
  around(:each) do |example|
    load_path_before = $LOAD_PATH.dup

    begin
      example.run
    ensure
      $LOAD_PATH.replace(load_path_before)
    end
  end
end