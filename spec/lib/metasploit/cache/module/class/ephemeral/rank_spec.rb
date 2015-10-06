RSpec.describe Metasploit::Cache::Module::Class::Ephemeral::Rank do
  context '#synchronize' do
    include_context 'ActiveSupport::TaggedLogging'

    subject(:synchronize) do
      described_class.synchronize(
          destination: destination,
          logger: logger,
          source: source
      )
    end

    let(:destination) {
      FactoryGirl.build(
          :metasploit_cache_auxiliary_class,
          rank: destination_rank
      ).tap { |direct_class|
        # Set to nil after build so that record passed to #persist must fill in the rank, but the built
        # template still contains a Rank like a real loading scenario.
        direct_class.rank = nil
      }
    }
    
    let(:destination_rank) {
      FactoryGirl.generate :metasploit_cache_module_rank
    }

    let(:source) {
      Class.new.tap { |metasploit_class|
        metasploit_class.extend Metasploit::Cache::Cacheable

        rank_number = destination_rank.number

        metasploit_class.define_singleton_method(:rank) do
          rank_number
        end
      }
    }

    context 'with #metasploit_class responds to #rank' do
      context 'with Metasploit::Cache::Module::Rank seeded' do
        it 'returns destination' do
          expect(synchronize).to eq(destination)
        end

        it 'sets destination.rank' do
          expect {
            synchronize
          }.to change(destination, :rank).to destination_rank
        end
      end

      context 'without Metasploit::Cache::Module:Rank seeded' do

        #
        # Callbacks
        #

        before(:each) do
          # cache before deleting
          destination_rank

          Metasploit::Cache::Module::Rank.delete_all
        end

        context 'with Metasploit::Cache::Module::Rank#number in Metasploit::Cache::Module::Rank::NAME_BY_NUMBER' do
          #
          # lets
          #

          let(:destination_rank) {
            Metasploit::Cache::Module::Rank.where(number: 100).first!
          }

          it 'logs error saying Metasploit::Cache::Module::Rank was not seeded' do
            synchronize

            expect(logger_string_io.string).to include('Metasploit::Cache::Module::Rank with #number (100) is not seeded')
          end
        end

        context 'without Metasploit::Cache::Module::Rank#number in Metasploit::Cache::Module::Rank::NAME_BY_NUMBER' do
          #
          # lets
          #

          let(:destination_rank) {
            Metasploit::Cache::Module::Rank.new(number: 150)
          }

          it 'logs an error saying Metasploit::Cache::Module::Rank#number is not valid' do
            synchronize

            expect(logger_string_io.string).to include(
                                                   'Metasploit::Cache::Module::Rank with #number (150) is not in ' \
                                                   'list of allowed #numbers (0, 100, 200, 300, 400, 500, and 600)'
                                               )
          end
        end
      end
    end

    context 'without #metasploit_class responds to #rank' do
      let(:destination) {
        FactoryGirl.build(
            :metasploit_cache_auxiliary_class,
            rank: destination_rank
        )
      }

      let(:source) {
        Class.new.tap { |metasploit_class|
          metasploit_class.extend Metasploit::Cache::Cacheable
        }
      }

      it 'returns destination' do
        expect(synchronize).to eq(destination)
      end

      it 'sets destination.rank to nil' do
        expect {
          synchronize
        }.to change(destination, :rank).to nil
      end
    end
  end
end