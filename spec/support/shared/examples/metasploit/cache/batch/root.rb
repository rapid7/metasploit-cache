shared_examples_for 'Metasploit::Cache::Batch::Root' do
  let(:error) do
    adapter = ActiveRecord::Base.connection_config[:adapter]

    case adapter
    when 'postgresql'
      ActiveRecord::RecordNotUnique.new("not unique", original_exception)
    when 'sqlite3'
      begin
        # Exception#cause can't be set explicitly so have to simulate what happens in the sqlite3 driver
        begin
          fail SQLite3::ConstraintException.new("UNIQUE constraint failed")
        rescue SQLite3::ConstraintException
          # will cause the SQLite3::ConstraintException as #cause
          raise ActiveRecord::StatementInvalid, "Wraps SQLite3::ConstraintException"
        end
      rescue ActiveRecord::StatementInvalid => active_record_statement_invalid
        active_record_statement_invalid
      end
    else
      fail ArgumentError, "Expected error for #{adapter.inspect} adapter unknown"
    end

  end

  let(:original_exception) do
    double('Original Exception')
  end

  context '#batched_save' do
    subject(:batched_save) do
      base_instance.batched_save
    end

    it 'should call Metasploit::Cache::Batch.batch' do
      expect(Metasploit::Cache::Batch).to receive(:batch)

      batched_save
    end

    it 'should call #recoverable_save' do
      expect(base_instance).to receive(:recoverable_save)

      batched_save
    end

    context 'with adapter-specific record not unique error raised' do
      before(:each) do
        expect(base_instance).to receive(:recoverable_save).and_raise(error)
      end

      it 'should call recoverable_save outside batch mode' do
        expect(base_instance).to receive(:recoverable_save) {
          expect(Metasploit::Cache::Batch).not_to be_batched
        }

        batched_save
      end
    end
  end

  context '#recoverable_save' do
    subject(:recoverable_save) do
      base_instance.recoverable_save
    end

    it 'should create a new transaction' do
      allow(base_instance).to receive(:save)

      expect(ActiveRecord::Base).to receive(:transaction).with(
          hash_including(
              requires_new: true
          )
      )

      recoverable_save
    end

    context 'inside another transaction' do
      context 'with an exception raised by save' do
        before(:each) do
          expect(base_instance).to receive(:save).and_raise(error)
        end

        it 'should not kill outer transaction' do
          ActiveRecord::Base.transaction do
            begin
              recoverable_save
            rescue error.class
              expect {
                Metasploit::Cache::Architecture.count
              }.not_to raise_error
            end
          end
        end
      end
    end
  end
end