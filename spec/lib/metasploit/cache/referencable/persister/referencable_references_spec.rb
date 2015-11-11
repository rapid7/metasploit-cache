RSpec.describe Metasploit::Cache::Referencable::Persister::ReferencableReferences do
  include_context 'ActiveSupport::TaggedLogging'

  context 'authority_abbreviation_set' do
    subject(:authority_abbreviation_set) {
      described_class.authority_abbreviation_set(attributes_set)
    }

    context 'with empty attributes_set' do
      let(:attributes_set) {
        Set.new
      }

      it { is_expected.to eq Set.new }
    end

    context 'with present attributes_set' do
      let(:attributes_set) {
        Set.new [attributes]
      }

      context 'with [:authority]' do
        let(:abbreviation) {
          FactoryGirl.generate :metasploit_cache_authority_abbreviation
        }

        let(:attributes) {
          {
              authority: {
                  abbreviation: abbreviation
              }
          }
        }

        it 'includes [:abbreviation]' do
          expect(authority_abbreviation_set).to include abbreviation
        end
      end

      context 'without [:authority]' do
        let(:attributes) {
          {
              url: FactoryGirl.generate(:metasploit_cache_reference_url)
          }
        }

        it { is_expected.to eq Set.new }
      end
    end
  end

  context 'authority_by_abbreviation' do
    subject(:authority_by_abbreviation) {
      described_class.authority_by_abbreviation(attributes_set)
    }

    context 'with empty attributes_set' do
      let(:attributes_set) {
        Set.new
      }

      it { is_expected.to eq Hash.new }
    end

    context 'with present attributes_set' do
      let(:attributes_set) {
        Set.new [attributes]
      }

      context 'with Metasploit::Cache::Authority#abbreviation from existing Metasploit::Cache::Authority' do
        let(:attributes) {
          {
              authority: {
                  abbreviation: authority.abbreviation
              },
              designation: FactoryGirl.generate(:metasploit_cache_reference_designation)
          }
        }

        let(:authority) {
          FactoryGirl.generate :seeded_metasploit_cache_authority
        }

        it 'maps Metasploit::Cache::Authority#abbreviation to Metasploit::Cache::Authority' do
          expect(authority_by_abbreviation[authority.abbreviation]).to eq(authority)
        end
      end

      context 'without Metasploit::Cache::Authority#abbreviation from existing Metasploit::Cache::Authority' do
        let(:abbreviation) {
          FactoryGirl.generate :metasploit_cache_authority_abbreviation
        }

        let(:attributes) {
          {
              authority: {
                  abbreviation: abbreviation
              },
              designation: FactoryGirl.generate(:metasploit_cache_reference_designation)
          }
        }

        it 'does not have Metasploit::Cache::Authority key' do
          expect(authority_by_abbreviation).not_to have_key(abbreviation)
        end
      end

      context 'without Metasploit::Cache::Authority#abbreviation' do
        let(:attributes) {
          {
              url: FactoryGirl.generate(:metasploit_cache_reference_url)
          }
        }

        it { is_expected.to eq Hash.new }
      end
    end
  end

  context 'build_added' do
    subject(:build_added) {
      described_class.build_added(
          destination: destination,
          destination_attributes_set: destination_attributes_set,
          logger: logger,
          source_attributes_set: source_attributes_set
      )
    }

    let(:destination) {
      Metasploit::Cache::Exploit::Instance.new
    }

    let(:destination_attributes_set) {
      Set.new
    }

    context 'with added' do
      let(:built_reference) {
        destination.referencable_references.first.reference
      }

      context 'with Metasploit::Cache::Authority#abbreviation and Metasploit::Cache::Reference#designation' do
        context 'with existing Metasploit::Cache::Authority' do
          let(:authority) {
            FactoryGirl.generate :seeded_metasploit_cache_authority
          }

          context 'with existing Metasploit::Cache::Reference' do
            let(:source_attributes_set) {
              Set.new [
                          {
                              authority: {
                                  abbreviation: authority.abbreviation
                              },
                              designation: reference.designation
                          }
                      ]
            }

            #
            # let!s
            #

            let!(:reference) {
              FactoryGirl.create(
                  :seeded_authority_metasploit_cache_reference,
                  authority: authority
              )
            }

            it 'adds #referencable_reference' do
              expect {
                build_added
              }.to change {
                     destination.referencable_references.length
                   }.by(1)
            end

            it 'uses existing Metasploit::Cache::Reference for Metasploit::Cache::Referencable::Reference#reference' do
              build_added

              expect(built_reference).to eq(reference)
            end

            it 'returns destination' do
              expect(build_added).to eq(destination)
            end
          end

          context 'without existing Metasploit::Cache::Reference' do
            let(:designation) {
              FactoryGirl.generate :metasploit_cache_reference_designation
            }

            let(:source_attributes_set) {
              Set.new [
                          {
                              authority: {
                                  abbreviation: authority.abbreviation
                              },
                              designation: designation
                          }
                      ]
            }

            it 'adds #referencable_reference' do
              expect {
                build_added
              }.to change {
                     destination.referencable_references.length
                   }.by(1)
            end

            context 'built Metasploit::Cache::Referencable::Reference#reference' do
              before(:each) do
                build_added
              end

              it 'is a newly created record' do
                expect(built_reference).to be_persisted
              end

              it 'set Metasploit::Cache::Reference#designation' do
                expect(built_reference.designation).to eq(designation)
              end

              context 'Metasploit::Cache::Reference#authority' do
                it 'uses existing Metasploit::Cache::Authority' do
                  expect(built_reference.authority).to eq(authority)
                end
              end
            end

            it 'returns destination' do
              expect(build_added).to eq(destination)
            end
          end
        end

        context 'without existing Metasploit::Cache::Authority' do
          let(:authority) {
            FactoryGirl.build(:metasploit_cache_authority)
          }

          let(:designation) {
            FactoryGirl.generate :metasploit_cache_reference_designation
          }

          let(:source_attributes_set) {
            Set.new [
                        {
                            authority: {
                                abbreviation: authority.abbreviation
                            },
                            designation: designation
                        }
                    ]
          }

          it 'adds #referencable_reference' do
            expect {
              build_added
            }.to change {
                   destination.referencable_references.length
                 }.by(1)
          end

          context 'built Metasploit::Cache::Referencable::Reference#reference' do
            before(:each) do
              build_added
            end

            it 'is a new record' do
              expect(built_reference).to be_new_record
            end

            it 'sets Metasploit::Cache::Reference#designation' do
              expect(built_reference.designation).to eq(designation)
            end

            context 'Metasploit::Cache::Reference#authority' do
              it 'is nil because unknown Metasploit::Cache::Authority#abbreviations must be registered' do
                expect(built_reference.authority).to be_nil
              end
            end
          end

          it 'returns destination' do
            expect(build_added).to eq(destination)
          end
        end
      end

      context 'with Metasploit::Cache::Reference#url' do
        let(:url) {
          FactoryGirl.generate :metasploit_cache_reference_url
        }

        let(:source_attributes_set) {
          Set.new [
                      {
                          url: url
                      }
                  ]
        }

        context 'with existing Metasploit::Cache::Reference' do
          let!(:reference) {
            Metasploit::Cache::Reference.create!(
                url: url
            )
          }

          it 'adds #referencable_reference' do
            expect {
              build_added
            }.to change {
                   destination.referencable_references.length
                 }.by(1)
          end

          context 'built Metasploit::Cache::Referencable::Reference#reference' do
            before(:each) do
              build_added
            end

            it 'is existing Metasploit::Cache::Reference' do
              expect(built_reference).to eq(reference)
            end

            context 'Metasploit::Cache::Reference#authority' do
              it 'is nil' do
                expect(built_reference.authority).to be_nil
              end
            end
          end

          it 'returns destination' do
            expect(build_added).to eq(destination)
          end
        end

        context 'without existing Metasploit::Cache::Reference' do
          it 'adds #referencable_reference' do
            expect {
              build_added
            }.to change {
                   destination.referencable_references.length
                 }.by(1)
          end

          context 'built Metasploit::Cache::Referencable::Reference#reference' do
            before(:each) do
              build_added
            end

            it 'is newly created record' do
              expect(built_reference).to be_persisted
            end

            it 'sets #url' do
              expect(built_reference.url).to eq(url)
            end

            context 'Metasploit::Cache::Reference#authority' do
              it 'is nil' do
                expect(built_reference.authority).to be_nil
              end
            end
          end

          it 'returns destination' do
            expect(build_added).to eq(destination)
          end
        end
      end
    end

    context 'without added' do

      let(:source_attributes_set) {
        Set.new
      }

      it 'does not add build any #referencable_references on destination' do
        expect {
          build_added
        }.not_to change {
                   destination.referencable_references.length
                 }
      end

      it 'returns destination' do
        expect(build_added).to eq(destination)
      end
    end
  end

  context 'destination_attributes_set' do
    subject(:destination_attributes_set) {
      described_class.destination_attributes_set(referencable_reference_by_attributes)
    }

    context 'with empty referencable_reference_by_attributes' do
      let(:referencable_reference_by_attributes) {
        {}
      }

      it { is_expected.to eq Set.new }
    end

    context 'with present referencable_reference_by_attributes' do
      let(:authority_reference_attributes) {
        {
            authority: {
                abbreviation: FactoryGirl.generate(:metasploit_cache_authority_abbreviation)
            },
            designation: FactoryGirl.generate(:metasploit_cache_reference_designation)
        }
      }

      let(:referencable_reference_by_attributes) {
        {
            authority_reference_attributes => double('authority Metasploit::Cache::Referencable::Reference'),
            url_reference_attributes => double('URL Metasploit::Cache::Referencable::Reference')
        }
      }

      let(:url_reference_attributes) {
        {
            url: FactoryGirl.generate(:metasploit_cache_reference_url)
        }
      }

      it 'is set of attributes' do
        expect(destination_attributes_set).to eq Set.new([authority_reference_attributes, url_reference_attributes])
      end
    end
  end

  context 'mark_removed_for_destruction' do
    subject(:mark_removed_for_destruction) do
      described_class.mark_removed_for_destruction(
                         destination: destination,
                         destination_attributes_set: destination_attributes_set,
                         referencable_reference_by_attributes: referencable_reference_by_attributes,
                         source_attributes_set: source_attributes_set
      )
    end

    context 'with new destination' do
      let(:destination) {
        Metasploit::Cache::Exploit::Instance.new
      }

      let(:destination_attributes_set) {
        Set.new
      }

      let(:referencable_reference_by_attributes) {
        {}
      }

      let(:source_attributes_set) {
        Set.new
      }

      it 'returns destination' do
        expect(mark_removed_for_destruction).to eq(destination)
      end
    end

    context 'with persisted destination' do
      let!(:destination) do
        FactoryGirl.create(
            :full_metasploit_cache_exploit_instance,
            referencable_reference_count: 1
        )
      end

      let(:destination_attributes_set) {
        Set.new [destination_reference_attributes]
      }

      let(:destination_referencable_reference) {
        destination.referencable_references.first
      }

      let(:destination_reference) {
        destination_referencable_reference.reference
      }

      let(:destination_reference_attributes) {
        {
            authority: {
                abbreviation: destination_reference.authority.abbreviation
            },
            designation: destination_reference.designation
        }
      }

      let(:referencable_reference_by_attributes) {
        {
            destination_reference_attributes => destination_referencable_reference
        }
      }

      context 'with removed' do
        let(:source_attributes_set) {
          Set.new
        }

        it 'marks for destruction Metasploit::Cache::Referencable::Reference with matching Metasploit::Cache::Reference attributes' do
          expect {
            mark_removed_for_destruction
          }.to change {
                 destination.referencable_references.each.count(&:marked_for_destruction?)
               }.to(1)
        end
      end

      context 'without removed' do
        let(:source_attributes_set) {
          destination_attributes_set
        }

        it 'marks for destruction no Metasploit::Cache::Referencable::References' do
          expect {
            mark_removed_for_destruction
          }.not_to change {
                 destination.referencable_references.each.count(&:marked_for_destruction?)
               }.from(0)
        end
      end
    end
  end

  context 'referencable_reference_by_attributes' do
    subject(:referencable_reference_by_attributes) {
      described_class.referencable_reference_by_attributes(destination)
    }

    context 'with new record' do
      let(:destination) {
        Metasploit::Cache::Exploit::Instance.new
      }

      it { is_expected.to eq Hash.new }
    end

    context 'with persisted destination' do
      let(:authority_referencable_reference) {
        Metasploit::Cache::Referencable::Reference.new(
            reference: authority_reference
        )
      }

      let(:authority_reference) {
        FactoryGirl.create(:seeded_authority_metasploit_cache_reference)
      }

      let(:authority_reference_attributes) {
        {
            authority: {
                abbreviation: authority_reference.authority.abbreviation
            },
            designation: authority_reference.designation
        }
      }

      let(:url_referencable_reference) {
        Metasploit::Cache::Referencable::Reference.new(
            reference: url_reference
        )
      }

      let(:url_reference) {
        FactoryGirl.create(:url_metasploit_cache_reference)
      }

      let(:url_reference_attributes) {
        {
            url: url_reference.url
        }
      }

      #
      # let!s
      #

      let!(:destination) {
        FactoryGirl.create(
            :metasploit_cache_exploit_instance,
            :metasploit_cache_contributable_contributions,
            :metasploit_cache_licensable_licensable_licenses,
            :metasploit_cache_exploit_instance_exploit_targets,
            :metasploit_cache_exploit_instance_exploit_class_ancestor_contents,
            referencable_references: [
                authority_referencable_reference,
                url_referencable_reference
            ]
        )
      }

      it 'maps Metasploit::Cache::Authority#abbreviation and Metasploit::Cache::Reference#designation to Metasploit::Cache::Referencable::Reference' do
        expect(referencable_reference_by_attributes[authority_reference_attributes]).to eq(authority_referencable_reference)
      end

      it 'maps Metasploit::Cache::Authority#designation to Metasploit::Cache::Referencable::Reference' do
        expect(referencable_reference_by_attributes[url_reference_attributes]).to eq(url_referencable_reference)
      end
    end
  end

  context 'source_attributes_set' do
    subject(:source_attributes_set) {
      described_class.source_attributes_set(source)
    }

    let(:source_attributes) {
      source_attributes_set.first
    }

    let(:reference) {
      double(
          'Metasploit Module instance reference',
          ctx_id: ctx_id,
          ctx_val: ctx_val
      )
    }

    let(:source) {
      double(
          'Metasploit Module instance',
          references: [reference]
      )
    }

    context 'ctx_id' do
      context "with 'URL'" do
        let(:ctx_id) {
          'URL'
        }

        let(:ctx_val) {
          FactoryGirl.generate :metasploit_cache_reference_url
        }

        it 'sets [:url] to ctx_val' do
          expect(source_attributes[:url]).to eq(ctx_val)
        end
      end

      context "without 'URL'" do
        let(:ctx_id) {
          'CVE'
        }

        let(:ctx_val) {
          FactoryGirl.generate :metasploit_cache_reference_cve_designation
        }

        it 'sets [:authority][:abbreviation] to ctx_id' do
          expect(source_attributes[:authority][:abbreviation]).to eq(ctx_id)
        end

        it 'sets [:designation] to ctx_val' do
          expect(source_attributes[:designation]).to eq(ctx_val)
        end
      end
    end
  end

  context 'synchronize' do
    subject(:synchronize) {
      described_class.synchronize(
                         destination: destination,
                         logger: logger,
                         source: source
      )
    }

    let(:destination) {
      Metasploit::Cache::Exploit::Instance.new
    }

    let(:source) {
      double('Metasploit Module instance', references: [])
    }

    it 'calls build_added' do
      expect(described_class).to receive(:build_added).with(
                                     hash_including(
                                         destination: destination
                                     )
                                 ).and_call_original

      synchronize
    end

    it 'calls mark_removed_for_destruction' do
      expect(described_class).to receive(:mark_removed_for_destruction).with(
                                     hash_including(
                                         destination: destination
                                     )
                                 ).and_call_original

      synchronize
    end
  end
end