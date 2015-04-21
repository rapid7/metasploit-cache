RSpec.shared_examples_for 'Metasploit::Cache::Batch::Root' do
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

    adapter = ActiveRecord::Base.connection_config[:adapter]

    case adapter
    when 'postgresql'
      context 'with PostgreSQL' do
        context 'with ActiveRecord::RecordNotUnique' do
          before(:each) do
            expect(base_instance).to receive(:recoverable_save).and_raise(
                                         ActiveRecord::RecordNotUnique.new("Record not unique", Exception.new)
                                     )
          end

          it 'should call recoverable_save outside batch mode' do
            expect(base_instance).to receive(:recoverable_save) {
                                       expect(Metasploit::Cache::Batch).not_to be_batched
                                     }

            batched_save
          end
        end

        context 'with ActiveRecord::StatementInvalid' do
          context 'with SQLite3::ConstraintException defined' do
            context '#cause' do
              context 'with SQLite3::ConstraintException' do
                before(:each) do
                  stub_const('SQLite3::ConstraintException', Class.new(StandardError))

                  expect(base_instance).to receive(:recoverable_save) {
                                             # Exception#cause can't be set explicitly so have to simulate what happens in the sqlite3 driver
                                             begin
                                               fail SQLite3::ConstraintException.new("UNIQUE constraint failed")
                                             rescue SQLite3::ConstraintException
                                               # will cause the SQLite3::ConstraintException as #cause
                                               raise ActiveRecord::StatementInvalid, "Wraps SQLite3::ConstraintException"
                                             end
                                           }
                end

                it 'should call recoverable_save outside batch mode' do
                  expect(base_instance).to receive(:recoverable_save) {
                                             expect(Metasploit::Cache::Batch).not_to be_batched
                                           }

                  batched_save
                end
              end

              context 'without SQLite3::ConstraintException' do
                before(:each) do
                  hide_const('SQLite3::ConstraintException')


                  expect(base_instance).to receive(:recoverable_save) {
                                             # Exception#cause can't be set explicitly so have to simulate what happens in the sqlite3 driver
                                             begin
                                               fail StandardError.new("Unknown cause")
                                             rescue
                                               # will cause the StandardError as #cause
                                               raise ActiveRecord::StatementInvalid, "Wraps unknown exception"
                                             end
                                           }
                end

                it 'reraises ActiveRecord::StatementInvalid' do
                  expect {
                    batched_save
                  }.to raise_error(ActiveRecord::StatementInvalid)
                end
              end
            end
          end

          context 'without SQLite3::ConstraintException defined' do
            before(:each) do
              expect(base_instance).to receive(:recoverable_save).and_raise(ActiveRecord::StatementInvalid)
            end

            it 'reraises ActiveRecord::StatementInvalid' do
              expect {
                batched_save
              }.to raise_error(ActiveRecord::StatementInvalid)
            end
          end
        end
      end
    when 'sqlite3'
      context 'with SQLite3' do
        context 'with ActiveRecord::StatementInvalid' do
          context 'with SQLite3::ConstraintException defined' do
            context '#cause' do
              context 'with SQLite3::ConstraintException' do
                before(:each) do
                  stub_const('SQLite3::ConstraintException', Class.new(StandardError))

                  expect(base_instance).to receive(:recoverable_save) {
                                             # Exception#cause can't be set explicitly so have to simulate what happens in the sqlite3 driver
                                             begin
                                               fail SQLite3::ConstraintException.new("UNIQUE constraint failed")
                                             rescue SQLite3::ConstraintException
                                               # will cause the SQLite3::ConstraintException as #cause
                                               raise ActiveRecord::StatementInvalid, "Wraps SQLite3::ConstraintException"
                                             end
                                           }
                end

                it 'should call recoverable_save outside batch mode' do
                  expect(base_instance).to receive(:recoverable_save) {
                                             expect(Metasploit::Cache::Batch).not_to be_batched
                                           }

                  batched_save
                end
              end

              context 'without SQLite3::ConstraintException' do
                before(:each) do
                  hide_const('SQLite3::ConstraintException')


                  expect(base_instance).to receive(:recoverable_save) {
                                             # Exception#cause can't be set explicitly so have to simulate what happens in the sqlite3 driver
                                             begin
                                               fail StandardError.new("Unknown cause")
                                             rescue
                                               # will cause the StandardError as #cause
                                               raise ActiveRecord::StatementInvalid, "Wraps unknown exception"
                                             end
                                           }
                end

                it 'reraises ActiveRecord::StatementInvalid' do
                  expect {
                    batched_save
                  }.to raise_error(ActiveRecord::StatementInvalid)
                end
              end
            end
          end

          context 'without SQLite3::ConstraintException defined' do
            before(:each) do
              expect(base_instance).to receive(:recoverable_save).and_raise(ActiveRecord::StatementInvalid)
            end

            it 'reraises ActiveRecord::StatementInvalid' do
              expect {
                batched_save
              }.to raise_error(ActiveRecord::StatementInvalid)
            end
          end
        end
      end
    else
      raise ArgumentError, 'Unknown adapter'
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
        #
        # Methods
        #

        def raise_adapter_error
          adapter = ActiveRecord::Base.connection_config[:adapter]

          case adapter
          when 'postgresql'
            fail ActiveRecord::RecordNotUnique.new("not unique", original_exception)
          when 'sqlite3'
            # Exception#cause can't be set explicitly so have to simulate what happens in the sqlite3 driver
            begin
              fail SQLite3::ConstraintException.new("UNIQUE constraint failed")
            rescue SQLite3::ConstraintException
              # will cause the SQLite3::ConstraintException as #cause
              raise ActiveRecord::StatementInvalid, "Wraps SQLite3::ConstraintException"
            end
          else
            fail ArgumentError, "Expected error for #{adapter.inspect} adapter unknown"
          end
        end

        #
        # lets
        #

        let(:error) do
          begin
            raise_adapter_error
          rescue => adapter_error
            adapter_error
          end
        end

        #
        # Callbacks
        #

        before(:each) do
          expect(base_instance).to receive(:save) {
                                     raise_adapter_error
                                   }
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