RSpec.describe Metasploit::Cache::Contributable::Ephemeral::Contributions do
  context 'added_author_name_set' do
    subject(:added_author_name_set) {
      described_class.added_author_name_set(added_attributes_set: added_attributes_set)
    }

    context 'with empty :added_attributes_set' do
      let(:added_attributes_set) {
        Set.new
      }

      it { is_expected.to eq(Set.new) }
    end

    context 'with present :added_attributes_set' do
      let(:added_attributes_set) {
        Set.new [
                    {
                        author: {
                            name: author_names[0]
                        }
                    },
                    {
                        author: {
                            name: author_names[1]
                        }
                    }
                ]
      }

      let(:author_names) {
        Array.new(2) {
          FactoryGirl.generate :metasploit_cache_author_name
        }
      }

      it 'is set of [:author][:name]s' do
        expect(added_author_name_set).to eq(Set.new(author_names))
      end
    end
  end

  context 'added_email_address_full_set' do
    subject(:added_email_address_full_set) {
      described_class.added_email_address_full_set(added_attributes_set: added_attributes_set)
    }

    context 'with empty :added_attributes_set' do
      let(:added_attributes_set) {
        Set.new
      }

      it { is_expected.to eq(Set.new) }
    end

    context 'with present :added_attributes_set' do
      context 'with [:email_address]' do
        let(:added_attributes_set) {
          Set.new [
                      {
                          email_address: {
                              full: email_address_fulls[0]
                          }
                      },
                      {
                          email_address: {
                              full: email_address_fulls[1]
                          }
                      }
                  ]
        }

        let(:email_address_fulls) {
          Array.new(2) {
            domain = FactoryGirl.generate :metasploit_cache_email_address_domain
            local = FactoryGirl.generate :metasploit_cache_email_address_local

            "#{local}@#{domain}"
          }
        }

        it 'is Set of [:email_address][:full]' do
          expect(added_email_address_full_set).to eq(Set.new(email_address_fulls))
        end
      end

      context 'without [:email_address]' do
        let(:added_attributes_set) {
          Set.new [
                      {},
                      {}
                  ]
        }

        it 'does not add entries to returned Set' do
          expect(added_email_address_full_set).to eq(Set.new)
        end
      end
    end
  end

  context 'build_added' do
    subject(:build_added) {
      described_class.build_added(
          destination: destination,
          destination_attributes_set: destination_attributes_set,
          source_attributes_set: source_attributes_set
      )
    }

    #
    # lets
    #

    let(:destination) {
      Metasploit::Cache::Auxiliary::Instance.new
    }

    let(:destination_attributes_set) {
      Set.new
    }

    context 'with added contributions' do
      let(:source_author_name) {
        FactoryGirl.generate :metasploit_cache_author_name
      }

      context 'with [:email_address]' do
        let(:source_attributes_set) {
          Set.new [
                      {
                          author: {
                              name: source_author_name
                          },
                          email_address: {
                              full: source_email_address_full
                          }
                      }
                  ]
        }

        let(:source_email_address_full) {
          domain = FactoryGirl.generate :metasploit_cache_email_address_domain
          local = FactoryGirl.generate :metasploit_cache_email_address_local

          "#{local}@#{domain}"
        }

        it 'builds contribution' do
          expect {
            build_added
          }.to change(destination.contributions, :length).by(1)
        end

        it 'sets Metasploit::Cache::Contribution#author Metasploit::Cache::Author#name to [:author][:name]' do
          expect(build_added.contributions.first.author.name).to eq(source_author_name)
        end

        it 'sets Metasploit::Cache::Contribution#email_address Metasploit::Cache::EmailAddress#full to [:email_address][:full]' do
          expect(build_added.contributions.first.email_address.full).to eq(source_email_address_full)
        end
      end

      context 'without [:email_address]' do
        let(:source_attributes_set) {
          Set.new [
                      {
                          author: {
                              name: source_author_name
                          }
                      }
                  ]
        }

        it 'builds contribution' do
          expect {
            build_added
          }.to change(destination.contributions, :length).by(1)
        end

        it 'sets Metasploit::Cache::Contribution#author Metasploit::Cache::Author#name to [:author][:name]' do
          expect(build_added.contributions.first.author.name).to eq(source_author_name)
        end

        it 'does not set Metasploit::Cache::Contribution#email_address' do
          expect(build_added.contributions.first.email_address).to be_nil
        end
      end
    end

    context 'without added contributions' do
      let(:source_attributes_set) {
        Set.new
      }

      it 'does not build contribution' do
        expect {
          build_added
        }.not_to change(destination.contributions, :length)
      end
    end
  end

  context 'contribution_by_attributes' do
    subject(:contribution_by_attributes) {
      described_class.contribution_by_attributes(destination)
    }

    let(:attributes) {
      contribution_by_attributes.keys.first
    }

    context 'with new destination' do
      let(:destination) {
        Metasploit::Cache::Auxiliary::Instance.new
      }

      it { is_expected.to eq({}) }
    end

    context 'with persisted destination' do
      let(:author) {
        FactoryGirl.create(:metasploit_cache_author)
      }

      context 'with Metasploit::Cache::Contributon#email_address' do
        let(:destination) {
          FactoryGirl.build(
              :metasploit_cache_auxiliary_instance,
              contribution_count: 0
          ).tap { |contributable|
            contributable.contributions.build(
                author: author,
                email_address: email_address
            )

            contributable.save!
          }
        }

        let(:email_address) {
          FactoryGirl.create(:metasploit_cache_email_address)
        }

        context 'attributes key' do
          it 'includes author.name as [:author][:name]' do
            expect(attributes[:author]).to eq({name: author.name})
          end

          it 'includes email_address.full as [:email_address][:full]' do
            expect(attributes[:email_address]).to eq({full: email_address.full})
          end
        end
      end

      context 'without Metasploit::Cache::Contributon#email_address' do
        let(:destination) {
          FactoryGirl.build(
              :metasploit_cache_auxiliary_instance,
              contribution_count: 0
          ).tap { |contributable|
            contributable.contributions.build(
                author: author
            )

            contributable.save!
          }
        }

        context 'attributes key' do
          it 'includes author.name as [:author][:name]' do
            expect(attributes[:author]).to eq({name: author.name})
          end

          it 'does not include [:email_address]' do
            expect(attributes).not_to have_key :email_address
          end
        end
      end
    end
  end

  context 'destination_attributes_set' do
    subject(:destination_attributes_set) {
      described_class.destination_attributes_set(contribution_by_attributes)
    }

    context 'with empty contribution_by_attributes' do
      let(:contribution_by_attributes) {
        {}
      }

      it { is_expected.to eq Set.new }
    end

    context 'with present contribution_by_attributes' do
      let(:attributes) {
        {
            author: {
                name: FactoryGirl.generate(:metasploit_cache_author_name)
            },
            email_address: {
                full: "#{FactoryGirl.generate(:metasploit_cache_email_address_local)}@#{FactoryGirl.generate(:metasploit_cache_email_address_domain)}"
            }
        }
      }

      let(:contribution_by_attributes) {
        {
            attributes => double('Metasploit::Cache::Contribution')
        }
      }

      it 'contains attributes' do
        expect(destination_attributes_set).to include(attributes)
      end
    end
  end

  context 'mark_removed_for_destruction' do
    subject(:mark_removed_for_destruction) {
      described_class.mark_removed_for_destruction(
                         contribution_by_attributes: contribution_by_attributes,
                         destination: destination,
                         destination_attributes_set: destination_attributes_set,
                         source_attributes_set: source_attributes_set
      )
    }

    let(:destination_attributes_set) {
      described_class.destination_attributes_set(contribution_by_attributes)
    }

    context 'with new record' do
      let(:destination) {
        Metasploit::Cache::Auxiliary::Instance.new
      }

      let(:contribution_by_attributes) {
        {}
      }

      let(:source_attributes_set) {
        Set.new
      }

      it 'does not change destination.contributions' do
        expect {
          mark_removed_for_destruction
        }.not_to change {
                   destination.contributions(true).count
                 }
      end
    end

    context 'with persisted record' do
      #
      # lets
      #

      let(:contribution_by_attributes) {
        {
            destination_attributes_array.first => destination.contributions.first,
            destination_attributes_array.second => destination.contributions.second
        }
      }

      let(:destination_attributes_array) {
        [
            {
                author: {
                    name: first_author.name
                },
                email_address: {
                    full: first_email_address.full
                }
            },
            {
                author: {
                    name: second_author.name
                }
            }
        ]
      }

      let(:destination_attributes_set) {
        Set.new destination_attributes_array
      }

      let(:first_author) {
        FactoryGirl.create(:metasploit_cache_author)
      }

      let(:first_email_address) {
        FactoryGirl.create(:metasploit_cache_email_address)
      }

      let(:second_author) {
        FactoryGirl.create(:metasploit_cache_author)
      }

      #
      # let!s
      #

      let!(:destination) {
        FactoryGirl.build(
                       :metasploit_cache_auxiliary_instance,
                       contribution_count: 0
        ).tap { |contributable|
          contributable.contributions.build(
              author: first_author,
              email_address: first_email_address
          )
          contributable.contributions.build(
              author: second_author
          )

          contributable.save!
        }
      }

      context 'with empty removed attributes set' do
        let(:source_attributes_set) {
          destination_attributes_set
        }

        it 'does not change destination.contributions' do
          expect {
            mark_removed_for_destruction
          }.not_to change {
                     destination.contributions(true).count
                   }
        end

        it 'does not mark and destination.contributions for destruction' do
          expect {
            mark_removed_for_destruction
          }.not_to change {
                     destination.contributions.each.count(&:marked_for_destruction?)
                   }
        end
      end

      context 'with present removed attributes set' do
        context 'with matching author.name' do
          context 'with email_address.full' do
            let(:source_attributes_set) {
              Set.new [
                          {
                              author: {
                                  name: second_author.name
                              }
                          }
                      ]
            }

            it 'marks for destruction contribution with both author.name AND email_address.full' do
              expect {
                mark_removed_for_destruction
              }.to change {
                     destination.contributions.each.count(&:marked_for_destruction?)
                   }.by(1)
            end

            it 'does not destroy any contributions' do
              expect {
                mark_removed_for_destruction
              }.not_to change(destination.contributions, :count)
            end

            context 'with saved destination' do
              it 'removes contribution with both author.name AND email_address.full' do
                mark_removed_for_destruction

                expect {
                  destination.save!
                }.to change(destination.contributions, :count).by(-1)

                expect(destination.contributions(true).map(&:author)).to include(second_author)
                expect(destination.contributions(true).map(&:email_address)).not_to include(first_email_address)
              end
            end
          end

          context 'with no email_addess.full' do
            let(:source_attributes_set) {
              Set.new [
                          {
                              author: {
                                  name: first_author.name
                              },
                              email_address: {
                                  full: first_email_address.full
                              }
                          }
                      ]
            }

            it 'marks for destruction contribution with only author.name' do
              expect {
                mark_removed_for_destruction
              }.to change {
                     destination.contributions.each.count(&:marked_for_destruction?)
                   }.by(1)
            end

            it 'does not destroy any contributions' do
              expect {
                mark_removed_for_destruction
              }.not_to change(destination.contributions, :count)
            end

            context 'with destination saved' do
              it 'removes contribution with only author.name' do
                mark_removed_for_destruction

                expect {
                  destination.save!
                }.to change(destination.contributions, :count).by(-1)

                expect(destination.contributions(true).map(&:author)).not_to include(second_author)
                expect(destination.contributions(true).map(&:email_address)).to include(first_email_address)
              end
            end
          end
        end

        context 'with multiple matches' do
          subject(:source_attributes_set) {
            Set.new
          }

          it 'marks for destruction all matching contributions' do
            expect {
              mark_removed_for_destruction
            }.to change {
                   destination.contributions.each.count(&:marked_for_destruction?)
                 }.by(2)
          end

          it 'does not destroy all contributions' do
            expect {
              mark_removed_for_destruction
            }.not_to change(destination.contributions, :count)
          end

          context 'with destination saved' do
            it 'removes all matching contributions' do
              mark_removed_for_destruction

              expect {
                destination.save!
              }.to change(destination.contributions, :count).by(-2)
            end
          end
        end
      end
    end
  end

  context 'source_attributes_set' do
    subject(:source_attributes_set) {
      described_class.source_attributes_set(source)
    }

    let(:source) {
      double('Metasploit Module instance').tap { |contributable|
        expect(contributable).to receive(:author).and_return(authors)
      }
    }

    context 'with empty author' do
      let(:authors) {
        []
      }

      it { is_expected.to eq(Set.new) }
    end

    context 'with present author' do
      let(:authors) {
        [
            author
        ]
      }

      let(:author) {
        double(
            'author',
            name: author_name,
            email: author_email
        )
      }

      let(:author_name) {
        FactoryGirl.generate :metasploit_cache_author_name
      }

      context 'with author.email' do
        let(:author_email) {
          domain = FactoryGirl.generate :metasploit_cache_email_address_domain
          local = FactoryGirl.generate :metasploit_cache_email_address_local

          "#{local}@#{domain}"
        }

        it 'includes author.email as [:email_address][:full]' do
          expect(source_attributes_set).to include(
                                               hash_including(
                                                   email_address: {
                                                       full: author_email
                                                   }
                                               )
                                           )
        end

        it 'includes author.name as [:author][:name]' do
          expect(source_attributes_set).to include(
                                               hash_including(
                                                   author: {
                                                       name: author_name
                                                   }
                                               )
                                           )
        end
      end

      context 'without author.email' do
        let(:author_email) {
          nil
        }

        it 'includes author.email as [:email_address][:full]' do
          expect(source_attributes_set).not_to include(
                                                   hash_including(
                                                       email_address: anything
                                                   )
                                               )
        end

        it 'includes author.name as [:author][:name]' do
          expect(source_attributes_set).to include(
                                               hash_including(
                                                   author: {
                                                       name: author_name
                                                   }
                                               )
                                           )
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
      Metasploit::Cache::Auxiliary::Instance.new
    }

    let(:logger) {
      double('ActiveSuppoort::TaggedLogger')
    }

    let(:source) {
      double('Metasploit Module instance', author: [])
    }

    it 'calls build_added' do
      expect(described_class).to receive(:build_added).with(
                                     hash_including(destination: destination)
                                 )

      synchronize
    end

    it 'calls mark_removed_for_destruction' do
      expect(described_class).to receive(:mark_removed_for_destruction).with(
                                     hash_including(destination: destination)
                                 )

      synchronize
    end
  end
end