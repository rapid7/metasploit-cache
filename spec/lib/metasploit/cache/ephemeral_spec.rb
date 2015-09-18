RSpec.describe Metasploit::Cache::Ephemeral do
  context '.create_unique' do
    subject(:create_unique) {
      described_class.create_unique(record_class, attributes)
    }

    let(:attributes) {
      {
          full: full
      }
    }

    let(:record_class) {
      Metasploit::Cache::EmailAddress
    }

    context 'with valid attributes' do
      let(:full) {
        "#{FactoryGirl.generate(:metasploit_cache_email_address_local)}@#{FactoryGirl.generate(:metasploit_cache_email_address_domain)}"
      }

      context 'with existing record before find' do
        let!(:existing_record) {
          record_class.create!(full: full)
        }

        it 'returns existing record' do
          expect(create_unique).to eq(existing_record)
        end
      end

      context 'with existing record after find, but before create' do
        include_context 'ActiveSupport::TaggedLogging'

        let(:existing_record) {
          record_class.create!(full: full)
        }

        before(:each) do
          ActiveRecord::Base.logger = logger

          allow_any_instance_of(record_class.all.class).to receive(:find_by).and_wrap_original { |method, *args|
                                                             found = method.call(*args)

                                                             existing_record

                                                             found
                                                           }
        end

        it 'returns existing record' do
          unique = create_unique

          expect(unique).to be_persisted
        end

        it 'logs debug message about number of retries' do
          create_unique

          expect(logger_string_io.string).to include('1st retry')
        end
      end

      context 'without record before create' do
        it 'returns newly created record' do
          expect {
            create_unique
          }.to change(record_class, :count).by(1)

          expect(create_unique).to be_persisted
        end
      end
    end

    context 'without valid attributes' do
      let(:full) {
        "invalid-email"
      }

      it 'returns invalid record' do
        expect(create_unique).to be_instance_of record_class
        expect(create_unique.errors.count).to be > 0
      end
    end
  end
end