shared_examples_for 'Metasploit::Cache::Batch::Root' do
  let(:error) do
    ActiveRecord::RecordNotUnique.new("not unique", original_exception)
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

    context 'with ActiveRecord::RecordNotUnique raised' do
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
            rescue ActiveRecord::RecordNotUnique
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