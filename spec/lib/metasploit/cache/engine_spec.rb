RSpec.describe Metasploit::Cache::Engine do
  context 'config' do
    subject(:config) do
      described_class.config
    end

    context 'generators' do
      subject(:generators) do
        config.generators
      end

      context 'options' do
        subject(:options) do
          generators.options
        end

        context 'factory_girl' do
          subject(:factory_girl) do
            options[:factory_girl]
          end

          context 'dir' do
            subject(:dir) do
              factory_girl[:dir]
            end

            it { is_expected.to eq('spec/factories')}
          end
        end

        context 'rails' do
          subject(:rails) do
            options[:rails]
          end

          it 'disables assets' do
            expect(rails[:assets]).to eq(false)
          end

          it 'uses FactoryGirl for fixtures' do
            expect(rails[:fixture_replacement]).to eq(:factory_girl)
          end

          it 'disables helpers' do
            expect(rails[:helper]).to eq(false)
          end

          it 'uses rspec for testing' do
            expect(rails[:test_framework]).to eq(:rspec)
          end
        end

        context 'rspec' do
          subject(:rspec) do
            options[:rspec]
          end

          it 'disables fixtures' do
            expect(rspec[:fixture]).to eq(false)
          end
        end
      end
    end
  end

  context 'initializers' do
    subject(:initializers) do
      # need to use Rails's initialized copy of Dummy::Application so that initializers have the correct context when
      # run
      Rails.application.initializers
    end

    context 'metasploit-cache.prepend_factory_path' do
      subject(:initializer) do
        initializers.find { |initializer|
          initializer.name == 'metasploit-cache.prepend_factory_path'
        }
      end

      it 'should run after factory_girl.set_factory_paths' do
        expect(initializer.after).to eq('factory_girl.set_factory_paths')
      end

      context 'running' do
        def run
          initializer.run
        end

        context 'with FactoryGirl defined' do
          it 'should prepend full path to spec/factories to FactoryGirl.definition_file_paths' do
            definition_file_path = Metasploit::Cache::Engine.root.join('spec', 'factories')

            expect(FactoryGirl.definition_file_paths).to receive(:unshift).with(definition_file_path)

            run
          end
        end
      end
    end
  end
end