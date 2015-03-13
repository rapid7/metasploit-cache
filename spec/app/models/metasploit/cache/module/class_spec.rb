RSpec.describe Metasploit::Cache::Module::Class do
  subject(:module_class) {
    FactoryGirl.build(:metasploit_cache_module_class)
  }

  context 'CONSTANTS' do
    context 'PAYLOAD_TYPES' do
      subject(:payload_types) do
        described_class::PAYLOAD_TYPES
      end

      it { should include('single') }
    end

    context 'STAGED_ANCESTOR_PAYLOAD_TYPES' do
      subject(:staged_ancestor_payload_types) do
        described_class::STAGED_ANCESTOR_PAYLOAD_TYPES
      end

      it { should include('stage') }
      it { should include('stager') }
    end
  end

  context 'derivations' do
    include_context 'ActiveRecord attribute_type'

    let(:base_class) {
      Metasploit::Cache::Module::Class
    }

    context 'with module_type derived' do
      before(:each) do
        module_class.module_type = module_class.derived_module_type
      end

      context 'with payload_type derived' do
        before(:each) do
          module_class.payload_type = module_class.derived_payload_type
        end

        context 'with payload module_type' do
          subject(:module_class) do
            FactoryGirl.build(
                :metasploit_cache_module_class,
                :module_type => 'payload'
            )
          end

          it_should_behave_like 'derives', :payload_type, :validates => true
          it_should_behave_like 'derives', :reference_name, :validates => true

          context 'with payload_type derived' do
            before(:each) do
              module_class.payload_type = module_class.derived_payload_type
            end

            context 'with reference_name derived' do
              before(:each) do
                module_class.reference_name = module_class.derived_reference_name
              end

              it_should_behave_like 'derives', :full_name, :validates => true
            end
          end
        end
      end

      context 'without payload module_type' do
        subject(:module_class) do
          FactoryGirl.build(
              :metasploit_cache_module_class,
              :module_type => module_type
          )
        end

        let(:module_type) do
          FactoryGirl.generate :metasploit_cache_non_payload_module_type
        end

        it_should_behave_like 'derives', :reference_name, :validates => true

        context 'with reference_name derived' do
          before(:each) do
            module_class.reference_name = module_class.derived_reference_name
          end

          it_should_behave_like 'derives', :full_name, :validates => true
        end
      end
    end

    it_should_behave_like 'derives', :module_type, :validates => true
  end

  context 'factories' do
    context :metasploit_cache_module_class do
      subject(:metasploit_cache_module_class) do
        FactoryGirl.build(:metasploit_cache_module_class)
      end

      it { should be_valid }

      context '#ancestors' do
        subject(:ancestors) do
          metasploit_cache_module_class.ancestors
        end

        context 'Metasploit::Cache::Module::Ancestor#contents list' do
          subject(:contents_list) do
            ancestors.map(&:contents)
          end

          before(:each) do
            # need to validate so that real_path is derived so contents can be read
            ancestors.each(&:valid?)
          end

          context 'metasploit_modules' do
            include_context 'Metasploit::Cache::Module::Ancestor#contents metasploit_module'

            subject(:metasploit_modules) do
              namespace_modules.collect { |namespace_module|
                namespace_module_metasploit_module(namespace_module)
              }
            end

            let(:namespace_modules) do
              ancestors.collect {
                Module.new
              }
            end

            before(:each) do
              namespace_modules.zip(contents_list) do |namespace_module, contents|
                namespace_module.module_eval(contents)
              end
            end

            context 'rank_names' do
              subject(:rank_names) do
                metasploit_modules.collect { |metasploit_module|
                  metasploit_module.rank_name
                }
              end

              it 'should match Metasploit::Cache::Module::Class#rank Metasploit::Cache:Module::Rank#name' do
                expect(
                    rank_names.all? { |rank_name|
                      rank_name == metasploit_cache_module_class.rank.name
                    }
                ).to eq(true)
              end
            end

            context 'rank_numbers' do
              subject(:rank_numbers) do
                metasploit_modules.collect { |metasploit_module|
                  metasploit_module.rank_number
                }
              end

              it 'should match Metasploit::Cache::Module::Class#rank Metasploit::Module::Module::Rank#number' do
                expect(
                    rank_numbers.all? { |rank_number|
                      rank_number == metasploit_cache_module_class.rank.number
                    }
                ).to eq(true)
              end
            end
          end
        end
      end

      context 'module_type' do
        subject(:metasploit_cache_module_class) do
          FactoryGirl.build(
              :metasploit_cache_module_class,
              :module_type => module_type
          )
        end

        context 'with payload' do
          let(:module_type) do
            'payload'
          end

          it { should be_valid }

          context 'with payload_type' do
            subject(:metasploit_cache_module_class) do
              FactoryGirl.build(
                  :metasploit_cache_module_class,
                  :module_type => module_type,
                  :payload_type => payload_type
              )
            end

            context 'single' do
              let(:payload_type) do
                'single'
              end

              it { should be_valid }
            end

            context 'other' do
              let(:payload_type) do
                'not_a_payload_type'
              end

              it 'should raise ArgumentError' do
                expect {
                  metasploit_cache_module_class
                }.to raise_error(ArgumentError)
              end
            end
          end
        end

        context 'without payload' do
          let(:module_type) do
            FactoryGirl.generate :metasploit_cache_non_payload_module_type
          end

          it { should be_valid }

          context '#derived_module_type' do
            subject(:derived_module_type) do
              metasploit_cache_module_class.derived_module_type
            end

            it 'matches #module_type' do
              expect(derived_module_type).to eq(module_type)
            end
          end
        end
      end

      context 'ancestors' do
        subject(:metasploit_cache_module_class) do
          FactoryGirl.build(
              :metasploit_cache_module_class,
              :ancestors => ancestors
          )
        end

        context 'single payload' do
          let!(:ancestors) do
            [
                FactoryGirl.create(:metasploit_cache_payload_single_ancestor)
            ]
          end

          it { should be_valid }
        end
      end
    end
  end

  context 'scopes' do
    context 'non_generic_payloads' do
      subject(:non_generic_payloads) {
        described_class.non_generic_payloads.to_a
      }

      let!(:generic_payload) {
        FactoryGirl.create(
            :metasploit_cache_module_class,
            ancestors: [
                generic_payload_ancestor
            ]
        )
      }

      let!(:generic_payload_ancestor) {
        FactoryGirl.create(
                       :metasploit_cache_payload_single_ancestor,
                       payload_name: 'generic/shell_bind_tcp'
        )
      }

      let!(:non_generic_payload) {
        FactoryGirl.create(
            :metasploit_cache_module_class,
            module_type: 'payload'
        )
      }

      it 'does not return generic payloads' do
        expect(non_generic_payloads).not_to include(generic_payload)
      end

      it 'returns generic payloads' do
        expect(non_generic_payloads).to include(non_generic_payload)
      end
    end

    context 'ranked' do
      subject(:ranked) {
        described_class.ranked.to_a
      }

      #
      # Methods
      #

      def ranked_class(rank_name)
        FactoryGirl.create(
            :metasploit_cache_module_class,
            rank: Metasploit::Cache::Module::Rank.where(name: rank_name).first
        )
      end

      #
      # let!s
      #

      let!(:average) {
        ranked_class('Average')
      }

      let!(:excellent) {
        ranked_class('Excellent')
      }

      let!(:good) {
        ranked_class('Good')
      }

      let!(:great) {
        ranked_class('Great')
      }

      let!(:low) {
        ranked_class('Low')
      }

      let!(:manaual) {
        ranked_class('Manual')
      }

      let!(:normal) {
        ranked_class('Normal')
      }

      it 'returns Metasploit::Cache::Module::Classes sorted by Metasploit::Cache::Module::Rank.number descending' do
        expect(ranked).to eq([excellent, great, good, normal, average, low, manaual])
      end
    end

    context 'with_module_instances' do
      subject(:with_module_instances) {
        described_class.with_module_instances(queried_module_instance_relation).to_a
      }

      #
      # lets
      #

      let(:expected_module_classes) {
        queried_module_instances.map(&:module_class)
      }

      let(:other_module_classes) {
        other_module_instances.map(&:module_class)
      }

      let(:queried_module_instance_relation) {
        Metasploit::Cache::Module::Instance.where(id: queried_module_instances.map(&:id))
      }

      #
      # let!s
      #

      let!(:other_module_instances) {
        FactoryGirl.create_list(:metasploit_cache_module_instance, 2)
      }

      let!(:queried_module_instances) {
        FactoryGirl.create_list(:metasploit_cache_module_instance, 2)
      }

      it 'returns Metasploit::Cache::Module::Classes correspond to Metasploit::Cache::Module::Instance#module_class' do
        expect(with_module_instances).to match_array(expected_module_classes)
      end

      it 'does not return other Metasploit::Cache::Module::Classes' do
        expect(with_module_instances).not_to include(other_module_classes[0])
        expect(with_module_instances).not_to include(other_module_classes[1])
      end
    end
  end

  context 'search' do
    let(:base_class) {
      Metasploit::Cache::Module::Class
    }

    context 'attributes' do
      it_should_behave_like 'search_attribute', :full_name, :type => :string
      it_should_behave_like 'search_attribute', :module_type, :type => :string
      it_should_behave_like 'search_attribute', :payload_type, :type => :string
      it_should_behave_like 'search_attribute', :reference_name, :type => :string
    end
  end

  context 'validations' do
    context 'ancestors' do
      context 'count' do
        subject(:module_class) do
          FactoryGirl.build(
              :metasploit_cache_module_class,
              :ancestors => ancestors,
              :module_type => module_type,
              :payload_type => payload_type
          )
        end

        before(:each) do
          # set explicitly so derivation doesn't cause other code path to run
          module_class.module_type = module_type
        end

        context 'with payload module_type' do
          let(:module_type) do
            'payload'
          end

          before(:each) do
            # set explicitly so derivation doesn't cause other code path to run
            module_class.payload_type = payload_type

            module_class.valid?
          end

          context 'with single payload_type' do
            let(:error) do
              'must have exactly one ancestor for single payload module class'
            end

            let(:payload_type) do
              'single'
            end

            context 'with 1 ancestor' do
              let(:ancestors) do
                [
                    FactoryGirl.create(:metasploit_cache_payload_single_ancestor)
                ]
              end

              it 'should not record error on ancestors' do
                expect(module_class.errors[:ancestors]).not_to include(error)
              end
            end

            context 'without 1 ancestor' do
              let(:ancestors) do
                []
              end

              it 'should record error on ancestors' do
                expect(module_class.errors[:ancestors]).to include(error)
              end
            end
          end
        end

        context 'without payload module_type' do
          let(:error) do
            'must have exactly one ancestor as a non-payload module class'
          end

          let(:module_type) do
            FactoryGirl.generate :metasploit_cache_non_payload_module_type
          end

          let(:payload_type) do
            nil
          end

          before(:each) do
            module_class.valid?
          end

          context 'with 1 ancestor' do
            let(:ancestor) {
              FactoryGirl.create(ancestor_factory)
            }

            let(:ancestor_factory) {
              FactoryGirl.generate :metasploit_cache_module_ancestor_factory
            }

            let(:ancestors) do
              [
                  ancestor
              ]
            end

            it 'should not record error on ancestors' do
              expect(module_class.errors[:ancestors]).not_to include(error)
            end
          end

          context 'without 1 ancestor' do
            let(:ancestors) do
              []
            end

            it 'records error on ancestors' do
              expect(module_class.errors[:ancestors]).to include(error)
            end
          end
        end
      end

      context 'module_types' do
        context 'between Metasploit::Cache::Module::Ancestor#module_type and Metasploit::Cache::Module::Class#module_type' do
          subject(:module_class) do
            FactoryGirl.build(
                :metasploit_cache_module_class,
                :module_type => module_type,
                :ancestors => ancestors
            )
          end

          def error(module_class, ancestor)
            "can contain ancestors only with same module_type (#{module_class.module_type}); " \
            "#{ancestor.module_type}/#{ancestor.reference_name} cannot be an ancestor due to its module_type " \
            "(#{ancestor.module_type})"
          end

          before(:each) do
            # Explicitly set module_type so its not derived, which could cause an alternate code path to be tested
            module_class.module_type = module_type

            module_class.valid?
          end

          context 'with module_type' do
            let(:module_type) do
              FactoryGirl.generate :metasploit_cache_non_payload_module_type
            end

            context 'with same Metasploit::Cache::Module::Ancestor#module_type and Metasploit::Cache::Module::Class#module_type' do
              let(:ancestor) {
                FactoryGirl.create(ancestor_factory)
              }

              let(:ancestor_factory) {
                Metasploit::Cache::Module::Ancestor::Spec::FACTORIES_BY_MODULE_TYPE.fetch(module_type).sample
              }

              let(:ancestors) do
                [
                    ancestor
                ]
              end

              it 'should not record on ancestors' do
                expect(module_class.errors[:ancestors]).not_to include(error(module_class, ancestors.first))
              end
            end

            context 'without same Metasploit::Cache::Module::Ancestor#module_type and Metasploit::Cache::Module::Class#module_type' do
              let(:ancestors) do
                [
                    FactoryGirl.create(:metasploit_cache_exploit_ancestor)
                ]
              end

              let(:module_type) do
                'nop'
              end

              it 'should record error on ancestors' do
                expect(module_class.errors[:ancestors]).to include(error(module_class, ancestors.first))
              end
            end
          end

          context 'without module_type' do
            # with a nil module_type, module_type will be derived from
            let(:ancestors) do
              Array.new(2) {
                factory = FactoryGirl.generate :metasploit_cache_module_ancestor_factory
                FactoryGirl.create(factory)
              }
            end

            let(:module_type) do
              nil
            end

            it 'should not record errors on ancestors' do
              ancestor_errors = module_class.errors[:ancestors]

              ancestors.each do |ancestor|
                ancestor_error = error(module_class, ancestor)

                expect(ancestor_errors).not_to include(ancestor_error)
              end
            end
          end
        end

        context 'between Metasploit::Cache::Module::Ancestor#module_types' do
          subject(:module_class) do
            FactoryGirl.build(
                :metasploit_cache_module_class,
                :ancestors => ancestors
            )
          end

          let(:error) do
            "can only contain ancestors with one module_type, " \
            "but contains multiple module_types (#{module_type_set.sort.to_sentence})"
          end

          before(:each) do
            module_class.valid?
          end

          context 'with same Metasploit::Cache::Module::Ancestor#module_type' do
            let(:ancestors) do
              FactoryGirl.create_list(ancestors_factory, 2)
            end

            let(:ancestors_factory) {
              Metasploit::Cache::Module::Ancestor::Spec::FACTORIES_BY_MODULE_TYPE[module_type].sample
            }

            let(:module_type) do
              FactoryGirl.generate :metasploit_cache_module_type
            end

            let(:module_type_set) do
              Set.new [module_type]
            end

            it 'should not record error on ancestors' do
              expect(module_class.errors[:ancestors]).not_to include(error)
            end
          end

          context 'without same Metasploit::Cache::Module::Ancestor#module_type' do
            let(:ancestors) do
              module_type_set.collect { |module_type|
                factory = Metasploit::Cache::Module::Ancestor::Spec::FACTORIES_BY_MODULE_TYPE.fetch(module_type).sample

                FactoryGirl.create(factory)
              }
            end

            let(:module_types) do
              [
                  FactoryGirl.generate(:metasploit_cache_module_type),
                  FactoryGirl.generate(:metasploit_cache_module_type)
              ]
            end

            let(:module_type_set) do
              Set.new module_types
            end

            it 'should record error on ancestors' do
              expect(module_class.errors[:ancestors]).to include(error)
            end
          end
        end
      end

      context 'payload_types' do
        subject(:module_class) do
          FactoryGirl.build(
              :metasploit_cache_module_class,
              :ancestors => ancestors,
              :module_type => module_type
          )
        end

        before(:each) do
          # explicitly set module_type so it is not derived from ancestors
          module_class.module_type = module_type
        end

        context "with 'payload' Metasploit::Cache::Module::Class#module_type" do
          let(:module_type) do
            'payload'
          end

          let(:ancestors) do
            [
                ancestor
            ]
          end

          context 'with Metasploit::Cache::Module::Class#payload_type' do
            before(:each) do
              # Explicitly set payload_type so it is not derived from ancestors
              module_class.payload_type = payload_type

              module_class.valid?
            end

            context 'single' do
              let(:error) do
                "cannot have an ancestor (#{ancestor.module_type}/#{ancestor.reference_name}) that is not a payload " \
                "for payload class"
              end

              let(:payload_type) do
                'single'
              end

              context "with 'single' Metasploit::Cache::Module::Ancestor#payload_type" do
                let(:ancestor) do
                  FactoryGirl.create(:metasploit_cache_payload_single_ancestor)
                end

                it 'should not record error on ancestors' do
                  expect(module_class.errors[:ancestors]).not_to include(error)
                end
              end
            end
          end
        end

        context "without 'payload' Metasploit::Cache::Module::Class#module_type" do
          let(:ancestors) do
            [
                ancestor
            ]
          end

          let(:error) do
            "cannot have an ancestor (#{ancestor.module_type}/#{ancestor.reference_name}) that is a payload with " \
            "for class module_type (#{module_type})"
          end

          let(:module_type) do
            FactoryGirl.generate :metasploit_cache_non_payload_module_type
          end

          before(:each) do
            module_class.valid?
          end

          context 'without Metasploit::Cache::Module::Ancestor#payload_type' do
            let(:ancestor) do
              FactoryGirl.create(ancestor_factory)
            end

            let(:ancestor_factory) {
              FactoryGirl.generate :metasploit_cache_non_payload_ancestor_factory
            }

            it 'should not record error on ancestors' do
              expect(module_class.errors[:ancestors]).not_to include(error)
            end
          end
        end
      end
    end

    context 'validates module_type inclusion in Metasploit::Cache::Module::Ancestor::MODULE_TYPES' do
      subject(:module_class) do
        FactoryGirl.build(
            :metasploit_cache_module_class,
            :ancestors => [],
            :module_type => module_type
        )
      end

      let(:error) do
        'is not included in the list'
      end

      before(:each) do
        module_class.module_type = module_type
      end

      Metasploit::Cache::Module::Type::ALL.each do |context_module_type|
        context "with #{context_module_type}" do
          let(:module_type) do
            context_module_type
          end

          it 'should not record error on module_type' do
            module_class.valid?

            expect(module_class.errors[:module_type]).not_to include(error)
          end
        end
      end

      context 'without module_type' do
        let(:module_type) do
          nil
        end

        it { should_not be_valid }

        it 'should record error on module_type' do
          module_class.valid?

          expect(module_class.errors[:module_type]).to include(error)
        end
      end
    end

    context 'payload_type' do
      subject(:module_class) do
        FactoryGirl.build(
            :metasploit_cache_module_class,
            :module_type => module_type
        )
      end

      before(:each) do
        module_class.payload_type = payload_type
      end

      context 'with payload' do
        let(:module_type) do
          'payload'
        end

        context 'with payload_type' do
          subject(:module_class) do
            FactoryGirl.build(
                :metasploit_cache_module_class,
                # Set explicitly so not derived from module_type and payload_type in factory, which will fail for the
                # invalid payload_type test.
                :ancestors => [],
                :module_type => module_type,
                :payload_type => payload_type
            )
          end

          let(:error) do
            'is not in list'
          end

          before(:each) do
            # Set explicitly so not derived
            module_class.payload_type = payload_type
          end

          context 'single' do
            let(:payload_type) do
              'single'
            end

            it 'should not record error' do
              module_class.valid?

              expect(module_class.errors[:payload_type]).not_to include(error)
            end
          end

          context 'staged' do
            let(:payload_type) do
              'staged'
            end

            it 'should not record error on payload_type' do
              module_class.valid?

              expect(module_class.errors[:payload_type]).not_to include(error)
            end
          end

          context 'other' do
            let(:payload_type) do
              'invalid_payload_type'
            end

            it 'should record error on payload_type' do
              module_class.valid?

              expect(module_class.errors[:payload_type]).not_to be_empty
            end
          end
        end
      end

      context 'without payload' do
        let(:error) do
          'must be nil'
        end

        let(:module_type) do
          FactoryGirl.generate :metasploit_cache_non_payload_module_type
        end

        before(:each) do
          module_class.payload_type = payload_type
        end

        context 'with payload_type' do
          let(:payload_type) do
            FactoryGirl.generate :metasploit_cache_module_class_payload_type
          end

          it 'should record error on payload_type' do
            module_class.valid?

            expect(module_class.errors[:payload_type]).to include(error)
          end
        end

        context 'without payload_type' do
          let(:payload_type) do
            nil
          end

          it 'should not error on payload_type' do
            module_class.valid?

            expect(module_class.errors[:payload_type]).not_to include(error)
          end
        end
      end
    end

    it { should validate_presence_of(:rank) }

    context 'with nil derived_reference_name' do
      before(:each) do
        allow(module_class).to receive(:derived_reference_name).and_return(nil)
      end

      it { should validate_presence_of(:reference_name) }
    end
  end

  context '#derived_module_type' do
    subject(:derived_module_type) do
      module_class.derived_module_type
    end

    context 'ancestors' do
      before(:each) do
        module_class.ancestors = ancestors
      end

      context 'empty' do
        let(:ancestors) do
          []
        end

        it { should be_nil }
      end

      context 'non-empty' do
        context 'with same Metasploit::Cache::Module::Ancestor#module_type' do
          let(:ancestors) do
            FactoryGirl.create_list(ancestors_factory, 2)
          end

          let(:ancestors_factory) {
            Metasploit::Cache::Module::Ancestor::Spec::FACTORIES_BY_MODULE_TYPE.fetch(module_type).sample
          }

          let(:module_type) do
            FactoryGirl.generate :metasploit_cache_module_type
          end

          it 'should return shared module_type' do
            expect(derived_module_type).to eq(module_type)
          end
        end

        context 'with different Metasploit::Cache::Module;:Ancestor#module_type' do
          let(:ancestors) do
            [
                FactoryGirl.create(:metasploit_cache_auxiliary_ancestor),
                FactoryGirl.create(:metasploit_cache_encoder_ancestor)
            ]
          end

          it 'should return nil because there is no consensus' do
            expect(derived_module_type).to be_nil
          end
        end
      end
    end
  end

  context '#derived_payload_type' do
    subject(:derived_payload_type) do
      module_class.derived_payload_type
    end

    before(:each) do
      module_class.module_type = module_type
    end

    context 'with payload' do
      let(:module_type) do
        'payload'
      end

      before(:each) do
        module_class.ancestors = ancestors
      end

      context 'with 1 ancestor' do
        context 'with single' do
          let(:ancestors) {
            [
                FactoryGirl.create(:metasploit_cache_payload_single_ancestor)
            ]
          }

          it { should == 'single' }
        end
      end
    end

    context 'without payload' do
      let(:module_type) do
        FactoryGirl.generate :metasploit_cache_non_payload_module_type
      end

      it { is_expected.to eq(nil) }
    end
  end

  context '#derived_reference_name' do
    subject(:derived_reference_name) do
      module_class.derived_reference_name
    end

    before(:each) do
      module_class.module_type = module_type
    end

    context 'with payload' do
      let(:module_type) do
        'payload'
      end

      before(:each) do
        module_class.payload_type = payload_type
      end

      context 'with single' do
        let(:payload_type) do
          'single'
        end

        it 'should call #derived_single_payload_reference_name' do
          expect(module_class).to receive(:derived_single_payload_reference_name)

          derived_reference_name
        end
      end

      context 'without single or staged' do
        let(:payload_type) do
          'invalid_payload_type'
        end

        it { should be_nil }
      end
    end

    context 'without payload' do
      let(:module_type) do
        FactoryGirl.generate :metasploit_cache_non_payload_module_type
      end

      before(:each) do
        module_class.ancestors = ancestors
      end

      context 'with 1 ancestor' do
        let(:ancestor) do
          FactoryGirl.create(ancestor_factory)
        end

        let(:ancestor_factory) {
          FactoryGirl.generate :metasploit_cache_module_ancestor_factory
        }

        let(:ancestors) do
          [
              ancestor
          ]
        end

        it 'should return reference_name of ancestor' do
          expect(derived_reference_name).to eq(ancestor.reference_name)
        end
      end

      context 'without 1 ancestor' do
        let(:ancestors) do
          Array.new(2) {
            factory = FactoryGirl.generate :metasploit_cache_module_ancestor_factory
            FactoryGirl.create(factory)
          }
        end

        it { should be_nil }
      end
    end
  end

  context '#derived_single_payload_reference_name' do
    subject(:derived_single_payload_reference_name) do
      module_class.send(:derived_single_payload_reference_name)
    end

    before(:each) do
      module_class.ancestors = ancestors
    end

    context 'with 1 ancestor' do
      let(:ancestors) do
        [
            ancestor
        ]
      end

      context 'with single' do
        let(:ancestor) do
          FactoryGirl.build(
              :metasploit_cache_payload_single_ancestor,
              content?: content?,
              relative_path: relative_path
          )
        end

        context 'with Metasploit::Cache::Module::Ancestor#relative_path' do
          let(:content?) {
            false
          }

          let(:payload_name) do
            'payload/name'
          end

          let(:relative_path) do
            "payloads/singles/#{payload_name}"
          end

          it 'should return Metasploit::Cache::Module::Ancestor#payload_name' do
            expect(derived_single_payload_reference_name).to eq(payload_name)
          end
        end

        context 'without Metasploit::Cache::Module::Ancestor#relative_path' do
          let(:content?) {
            false
          }

          let(:relative_path) do
            nil
          end

          it { is_expected.to be_nil }
        end
      end
    end

    context 'without 1 ancestor' do
      let(:ancestors) do
        []
      end

      it { should be_nil }
    end
  end

  context '#payload?' do
    subject(:payload?) do
      module_class.payload?
    end

    # use new instead of factory so that payload? won't be called in the background to show this context supplies
    # coverage
    let(:module_class) do
      described_class.new
    end

    before(:each) do
      module_class.module_type = module_type
    end

    context 'with payload' do
      let(:module_type) do
        'payload'
      end

      it { is_expected.to eq(true) }
    end

    context 'without payload' do
      let(:module_type) do
        FactoryGirl.generate :metasploit_cache_non_payload_module_type
      end

      it { is_expected.to eq(false) }
    end
  end
end