RSpec.describe Metasploit::Cache::Reference::Persister do
  include_context 'ActiveSupport::TaggedLogging'

  context 'attributes' do
    subject(:attributes) {
      described_class.attributes(reference)
    }

    context 'with Metasploit::Cache::Reference#authority' do
      let(:authority) {
        Metasploit::Cache::Authority.new(abbreviation: authority_abbreviation)
      }

      let(:authority_abbreviation) {
        FactoryGirl.generate :metasploit_cache_authority_abbreviation
      }

      let(:designation) {
        FactoryGirl.generate :metasploit_cache_reference_designation
      }

      let(:reference) {
        Metasploit::Cache::Reference.new(
            authority: authority,
            designation: designation
        )
      }

      it 'has Metasploit::Cache::Reference#authority Metasploit::Cache::Authority#abbreviation as [:authority][:abbreviation]' do
        authority_attributes = attributes[:authority]

        expect(authority_attributes).to be_a Hash
        expect(authority_attributes[:abbreviation]).to eq(authority_abbreviation)
      end

      it 'has Metasploit::Cache::Reference#designation as [:designation]' do
        expect(attributes[:designation]).to eq(designation)
      end
    end

    context 'without Metasploit:Cache::Reference#authority' do
      let(:reference) {
        Metasploit::Cache::Reference.new(
            url: url
        )
      }

      let(:url) {
        FactoryGirl.generate :metasploit_cache_reference_url
      }

      it 'has Metasploit::Cache::Reference#url as [:url]' do
        expect(attributes[:url]).to eq(url)
      end
    end
  end

  context 'by_attributes' do
    subject(:by_attributes) {
      described_class.by_attributes(
          attributes_set: attributes_set,
          authority_by_abbreviation: authority_by_abbreviation,
          logger: logger
      )
    }

    let(:attributes_set) {
      Set.new [
                  {
                      authority: {
                          abbreviation: FactoryGirl.generate(:metasploit_cache_authority_abbreviation)
                      },
                      designation: FactoryGirl.generate(:metasploit_cache_reference_designation)
                  },
                  {
                      url: FactoryGirl.generate(:metasploit_cache_reference_url)
                  }
              ]
    }

    let(:authority) {
      FactoryGirl.create(:metasploit_cache_authority)
    }

    let(:authority_by_abbreviation) {
      {
          authority.abbreviation => authority
      }
    }

    it 'looks up existing Metasploit::Cache::References using attributes_set and authority_by_abbrevation' do
      expect(described_class).to receive(:existing_by_attributes).with(
                                     hash_including(
                                         attributes_set: attributes_set,
                                         authority_by_abbreviation: authority_by_abbreviation
                                     )
                                 ).and_return({})

      by_attributes
    end

    it 'calls new_by_attributes_proc with authority_by_abbreviation' do
      expect(described_class).to receive(:new_by_attributes_proc).with(
                                     hash_including(
                                         authority_by_abbreviation: authority_by_abbreviation
                                     )
                                 )

      by_attributes
    end

    it 'sets Hash#default_proc to proc returned by new_by_attributes_proc' do
      new_by_attributes_proc = ->(hash, attributes) {}

      allow(described_class).to receive(:new_by_attributes_proc).and_return(new_by_attributes_proc)

      expect(by_attributes.default_proc).to eq(new_by_attributes_proc)
    end
  end

  context 'condition' do
    subject(:condition) {
      described_class.condition(
          attributes: attributes,
          authority_by_abbreviation: authority_by_abbreviation
      )
    }

    context 'with [:authority]' do
      let(:designation) {
        FactoryGirl.generate :metasploit_cache_reference_designation
      }

      context 'with [:abbreviation] in authority_by_abbreviation' do
        let(:attributes) {
          {
              authority: {
                  abbreviation: authority.abbreviation
              },
              designation: designation
          }
        }

        let(:authority) {
          FactoryGirl.generate :seeded_metasploit_cache_authority
        }

        let(:authority_by_abbreviation) {
          {
              authority.abbreviation => authority
          }
        }

        it 'returns AND between equalities on authority_id and designation' do
          expect(condition).to eq Arel::Nodes::And.new(
                                      Metasploit::Cache::Reference.arel_table[:authority_id].eq(authority.id),
                                      Metasploit::Cache::Reference.arel_table[:designation].eq(designation)
                                  )
        end
      end

      context 'without [:abbreviation] in authority_by_abbreviation' do
        let(:attributes) {
          {
              authority: {
                  abbreviation: FactoryGirl.generate(:metasploit_cache_authority_abbreviation)
              },
              designation: designation
          }
        }

        let(:authority_by_abbreviation) {
          {}
        }

        it { is_expected.to be_nil }
      end
    end

    context 'without [:authority]' do
      let(:attributes) {
        {
            url: url
        }
      }

      let(:authority_by_abbreviation) {
        {}
      }

      let(:url) {
        FactoryGirl.generate :metasploit_cache_reference_url
      }

      it 'returns equality on url' do
        expect(condition).to eq(Metasploit::Cache::Reference.arel_table[:url].eq(url))
      end
    end
  end

  context 'conditions' do
    subject(:conditions) {
      described_class.conditions(
          attributes_set: attributes_set,
          authority_by_abbreviation: authority_by_abbreviation
      )
    }

    context 'with empty attributes_set' do
      let(:attributes_set) {
        Set.new
      }

      let(:authority_by_abbreviation) {
        {}
      }

      it { is_expected.to eq [] }
    end

    context 'with present attributes_set' do
      let(:attributes) {
        {
            authority: {
                abbreviation: authority.abbreviation
            },
            designation: designation
        }
      }

      let(:attributes_set) {
        Set.new [attributes]
      }

      let(:authority) {
        FactoryGirl.generate :seeded_metasploit_cache_authority
      }

      let(:authority_by_abbreviation) {
        {
            authority.abbreviation => authority
        }
      }

      let(:designation) {
        FactoryGirl.generate :metasploit_cache_reference_designation
      }

      it 'calls condition with attributes and authority_by_abbreviation' do
        expect(described_class).to receive(:condition).with(
                                       hash_including(
                                           attributes: attributes,
                                           authority_by_abbreviation: authority_by_abbreviation
                                       )
                                   )

        conditions
      end

      context 'with nil condition' do
        before(:each) do
          allow(described_class).to receive(:condition).and_return(nil)
        end

        it 'does not include nil in returned Array' do
          expect(conditions).to eq([])
        end
      end

      context 'without nil condition' do
        it 'includes condition in returned Array' do
          condition = nil

          allow(described_class).to receive(:condition).and_wrap_original { |method, *args|
                                      condition = method.call(*args)
                                    }

          expect(conditions).to eq [condition]
        end
      end
    end
  end

  context 'existing_by_attributes' do
    subject(:existing_by_attributes) {
      described_class.existing_by_attributes(
          attributes_set: attributes_set,
          authority_by_abbreviation: authority_by_abbreviation
      )
    }

    context 'with empty attributes_set' do
      let(:attributes_set) {
        Set.new
      }

      let(:authority_by_abbreviation) {
        {}
      }

      it { is_expected.to eq({}) }
    end

    context 'with present attributes_set' do
      context 'with single element' do
        let(:attributes_set) {
          Set.new [attributes]
        }

        context 'with authority' do
          #
          # lets
          #

          let(:attributes) {
            {
                authority: {
                    abbreviation: authority.abbreviation
                },
                designation: designation
            }
          }

          let(:authority) {
            FactoryGirl.generate :seeded_metasploit_cache_authority
          }

          let(:authority_by_abbreviation) {
            {
                authority.abbreviation => authority
            }
          }

          let(:designation) {
            FactoryGirl.generate(:metasploit_cache_reference_designation)
          }

          context 'with existing Metasploit::Cache::Reference' do
            let!(:reference) {
              Metasploit::Cache::Reference.create!(
                  authority: authority,
                  designation: designation
              )
            }

            it 'maps Metasploit::Cache::Reference#authority Metasploit::Cache::Authority#abbreviation and Metasploit::Cache::Reference#designation to existing Metasploit::Cache::Reference' do
              expect(existing_by_attributes[attributes]).to eq(reference)
            end
          end

          context 'without existing Metasploit::Cache::Reference' do
            it 'does not have entry for Metasploit::Cache::Reference#authority Metasploit::Cache::Authority#abbreviation and Metasploit::Cache::Reference#designation' do
              expect(existing_by_attributes).not_to have_key(attributes)
            end
          end
        end

        context 'without authority' do
          let(:attributes) {
            {
                url: url
            }
          }

          let(:authority_by_abbreviation) {
            {}
          }

          let(:url) {
            FactoryGirl.generate :metasploit_cache_reference_url
          }

          context 'with existing Metasploit::Cache::Reference' do
            let!(:reference) {
              Metasploit::Cache::Reference.create!(
                  url: url
              )
            }

            it 'maps Metasploit::Cache::Reference#url to existing Metasploit::Cache::Reference' do
              expect(existing_by_attributes[attributes]).to eq(reference)
            end
          end

          context 'without existing Metasploit::Cache::Reference' do
            it 'does not have entry for Metasploit::Cache::Reference#url' do
              expect(existing_by_attributes).not_to have_key(attributes)
            end
          end
        end
      end

      context 'with multiple elements' do
        let(:attributes_set) {
          Set.new [
              authority_attributes,
              url_attributes
          ]
        }

        let(:authority_attributes) {
          {
              authority: {
                  abbreviation: authority_reference.authority.abbreviation
              },
              designation: authority_reference.designation
          }
        }

        let(:authority_by_abbreviation) {
          {
              authority_reference.authority.abbreviation => authority_reference.authority
          }
        }

        let(:url) {
          url_reference.url
        }

        let(:url_attributes) {
          {
              url: url
          }
        }

        #
        # let!s
        #

        let!(:authority_reference) {
          FactoryGirl.create(:seeded_authority_metasploit_cache_reference)
        }

        let!(:url_reference) {
          FactoryGirl.create(:url_metasploit_cache_reference)
        }

        it 'maps all elements' do
          expect(existing_by_attributes[authority_attributes]).to eq authority_reference
          expect(existing_by_attributes[url_attributes]).to eq url_reference
        end
      end
    end
  end

  context 'new_by_attributes_proc' do
    subject(:new_by_attributes_proc) {
      described_class.new_by_attributes_proc(
          authority_by_abbreviation: authority_by_abbreviation,
          logger: logger
      )
    }

    let(:hash) {
      Hash.new
    }

    context 'with [:authority]' do
      let(:attributes) {
        {
            authority: {
                abbreviation: authority_abbreviation
            },
            designation: designation
        }
      }

      let(:designation) {
        FactoryGirl.generate :metasploit_cache_reference_designation
      }

      context 'with [:abbreviation] in authority_by_abbreviation' do
        let(:authority) {
          FactoryGirl.generate :seeded_metasploit_cache_authority
        }

        let(:authority_abbreviation) {
          authority.abbreviation
        }

        let(:authority_by_abbreviation) {
          {
              authority_abbreviation => authority
          }
        }

        it 'maps attributes to Metasploit::Cache::Reference with #authority and #designation' do
          new_by_attributes_proc.call(hash, attributes)
          reference = hash[attributes]

          expect(reference).to be_a Metasploit::Cache::Reference
          expect(reference.authority).to eq authority
          expect(reference.designation).to eq designation
        end
      end

      context 'without [:abbreviation] in authority_by_abbreviation' do
        let(:authority_abbreviation) {
          FactoryGirl.generate :metasploit_cache_authority_abbreviation
        }

        let(:authority_by_abbreviation) {
          {}
        }

        it 'maps attributes to Metasploit::Cache::Reference with #designation' do
        new_by_attributes_proc.call(hash, attributes)
        reference = hash[attributes]

        expect(reference).to be_a Metasploit::Cache::Reference
        expect(reference.authority).to be_nil
        expect(reference.designation).to eq designation
        expect(reference.url).to be_nil
        end
      end
    end

    context 'without [:authority]' do
      let(:attributes) {
        {
            url: url
        }
      }

      let(:authority_by_abbreviation) {
        {}
      }

      let(:url) {
        FactoryGirl.generate :metasploit_cache_reference_url
      }

      it 'maps attributes to Metasploit::Cache::Reference with #url' do
        new_by_attributes_proc.call(hash, attributes)
        reference = hash[attributes]

        expect(reference).to be_a Metasploit::Cache::Reference
        expect(reference.authority).to be_nil
        expect(reference.designation).to be_nil
        expect(reference.url).to eq url
      end
    end
  end

  context 'union_conditions' do
    subject(:union_conditions) {
      described_class.union_conditions(conditions)
    }

    let(:authority) {
      FactoryGirl.generate :seeded_metasploit_cache_authority
    }

    let(:authority_condition) {
      Metasploit::Cache::Reference.arel_table[:authority_id].eq(authority.id).and(
          Metasploit::Cache::Reference.arel_table[:designation].eq(designation)
      )
    }

    let(:conditions) {
        [
            authority_condition,
            url_condition
        ]
    }

    let(:designation) {
      FactoryGirl.generate :metasploit_cache_reference_designation
    }

    let(:url) {
      FactoryGirl.generate :metasploit_cache_reference_url
    }

    let(:url_condition) {
      Metasploit::Cache::Reference.arel_table[:url].eq(url)
    }

    it 'ORs together conditions' do
      expect(union_conditions).to eq authority_condition.or(url_condition)
    end
  end
end