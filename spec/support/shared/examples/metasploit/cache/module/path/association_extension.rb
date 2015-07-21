RSpec.shared_examples_for 'Metasploit::Cache::Module::Path::AssociationExtension' do |association:, factory:, relative_path_prefix:|
  context association.to_s do
    subject(:target) {
      module_path.send(association)
    }

    let(:module_path) {
      FactoryGirl.build(:metasploit_cache_module_path)
    }

    context '#each_changed' do
      subject(:each_changed) do
        target.each_changed(options, &block)
      end

      #
      # lets
      #

      let(:new_module_ancestors) do
        # makes file on disk, but not Metasploit::Cache::Module::Ancestor record in database
        FactoryGirl.build_list(factory, 2, parent_path: module_path)
      end

      let(:options) do
        {
            assume_changed: true
        }
      end

      #
      # let!s
      #

      let!(:existing_module_ancestors) do
        FactoryGirl.create_list(factory, 2, parent_path: module_path)
      end

      #
      # Callbacks
      #

      before(:each) do
        # validate to derive real_path
        new_module_ancestors.each(&:valid?)
      end

      context 'with block' do
        let(:block) do
          lambda { |module_ancestor|
          }
        end

        let(:existing_module_ancestor_relative_paths) do
          existing_module_ancestors.map(&:relative_path)
        end

        let(:new_module_ancestor_relative_paths) do
          new_module_ancestors.map(&:relative_path)
        end

        it 'use #relative_paths to gather Metasploit::Cache::Module::Ancestor#relative_path' do
          expect(target).to receive(:relative_paths).and_return([])

          each_changed
        end

        it 'call ActiveRecord::Base.connection_pool.with_connection around database accesses' do
          expect(ActiveRecord::Base.connection_pool).to receive(:with_connection) do |&block|
            new = double('ActiveRecord::Association#new')
            where_relation = double('ActiveRecord::Relation#where', find_each: nil)
            with_connection = double(
                'With Connection',
                new: new,
                where: where_relation
            )

            with_connection.instance_eval(&block)
          end

          each_changed
        end

        it 'uses one query to find all updatable Metasploit::Cache::Module::Ancestors' do
          expect(target).to receive(:where).once.and_call_original

          each_changed
        end

        context ':assume_changed option' do
          context 'with true' do
            let(:options) do
              {
                  assume_changed: true
              }
            end

            it 'should yield existing and new Metasploit::Cache::Module::Ancestors' do
              changed_module_ancestors = target.each_changed(options)

              existing_module_ancestors.each do |existing_module_ancestor|
                expect(changed_module_ancestors).to include(existing_module_ancestor)
              end

              actual_relative_paths = changed_module_ancestors.map(&:relative_path)

              new_module_ancestor_relative_paths.each do |relative_path|
                expect(actual_relative_paths).to include(relative_path)
              end
            end
          end

          context 'with false' do
            subject(:changed_module_ancestors) do
              target.each_changed(options).to_a
            end

            let(:options) do
              {
                  assume_changed: false
              }
            end

            context 'without change to file modification time' do
              it 'should yield only new Metasploit::Cache::Module::Ancestors' do
                actual_relative_paths = changed_module_ancestors.map(&:relative_path)

                expect(
                    changed_module_ancestors.all? { |module_ancestor|
                      module_ancestor.new_record?
                    }
                ).to eq(true)

                expect(actual_relative_paths).to match_array(new_module_ancestor_relative_paths)
              end
            end

            context 'with change to file modification time' do
              def change_real_path_modification_time(module_ancestor)
                changed_time_with_zone = module_ancestor.real_path_modified_at + 5.seconds
                changed_time = changed_time_with_zone.time()
                File.utime(changed_time, changed_time, module_ancestor.real_pathname.to_path)
              end

              context 'with change to file contents' do
                def change_contents(module_ancestor)
                  module_ancestor.real_pathname.open('a') do |f|
                    f.puts "# Change to contents"
                  end
                end

                before(:each) do
                  existing_module_ancestors.each do |existing_module_ancestor|
                    change_contents(existing_module_ancestor)
                    # have to change modification time after changing contents as changing contents will write to the
                    # file, which will update atime and mtime.
                    change_real_path_modification_time(existing_module_ancestor)
                  end
                end

                it 'should return all Metasploit::Cache::module::Ancestors' do
                  actual_relative_paths = changed_module_ancestors.map(&:relative_path)

                  existing_module_ancestors.each do |existing_module_ancestor|
                    expect(actual_relative_paths).to include(existing_module_ancestor.relative_path)
                  end

                  new_module_ancestors.each do |new_module_ancestor|
                    expect(actual_relative_paths).to include(new_module_ancestor.relative_path)
                  end
                end

                context 'existing Metasploit::Cache::Module::Ancestors' do
                  it 'should update #real_path_modified_at' do
                    existing_module_ancestors.each do |existing_module_ancestor|
                      changed_module_ancestor = changed_module_ancestors.find { |changed_module_ancestor|
                        changed_module_ancestor == existing_module_ancestor
                      }

                      expect(changed_module_ancestor.real_path_modified_at).not_to eq(existing_module_ancestor.real_path_modified_at)
                    end
                  end

                  it 'should update #real_path_sha1_hex_digest' do
                    existing_module_ancestors.each do |existing_module_ancestor|
                      changed_module_ancestor = changed_module_ancestors.find { |changed_module_ancestor|
                        changed_module_ancestor == existing_module_ancestor
                      }

                      expect(changed_module_ancestor.real_path_sha1_hex_digest).not_to eq(existing_module_ancestor.real_path_sha1_hex_digest)
                    end
                  end
                end
              end

              context 'without change to file contents' do
                before(:each) do
                  existing_module_ancestors.each do |existing_module_ancestor|
                    change_real_path_modification_time(existing_module_ancestor)
                  end
                end

                it 'should not return pre-existing Metasploit::Cache::Module::Ancestor because real_path_sha1_hex_digest has not changed' do
                  existing_module_ancestors.each do |existing_module_ancestor|
                    expect(changed_module_ancestors).not_to include(existing_module_ancestor)
                  end
                end
              end
            end
          end
        end

        context ':progress_bar option' do
          context 'with ruby ProgressBar' do
            #
            # lets
            #

            let(:options) do
              {
                  progress_bar: progress_bar
              }
            end

            let(:output) do
              # adapted from https://github.com/jfelchner/ruby-progressbar/blob/5483cf834a74018e8a0c2091e1939d1981de9a2b/spec/lib/ruby-progressbar/base_spec.rb
              StringIO.new('', 'w+').tap { |string_io|
                allow(string_io).to receive(:tty?).and_return(true)
              }
            end

            let(:progress_bar) do
              ProgressBar::Base.new(
                  output: output,
                  throttle_rate: 0.0
              )
            end

            it 'should set #total to #relative_paths #length' do
              expected_total = target.send(:relative_paths).length

              expect(progress_bar).to receive(:total=).with(expected_total).and_call_original

              each_changed
            end

            context 'updatable module ancestors' do
              let(:new_module_ancestors) do
                []
              end

              context 'with changed' do
                let(:options) do
                  super().merge(
                      assume_changed: true
                  )
                end

                it 'should increment progress bar with yielding' do
                  actual_relative_paths = []

                  target.each_changed(options) { |module_ancestor|
                    actual_relative_paths << module_ancestor.relative_path
                  }

                  expect(actual_relative_paths).to match_array(existing_module_ancestor_relative_paths)
                  expect(progress_bar).to be_finished
                end

                it 'should increment progress bar after yieldreturn' do
                  expected_progress = 0

                  target.each_changed(options) { |_|
                    expect(progress_bar.progress).to eq(expected_progress)
                    expected_progress += 1
                  }
                  expect(progress_bar.progress).to eq(expected_progress)
                end
              end

              context 'without changed' do
                let(:options) do
                  super().merge(
                      assume_changed: false
                  )
                end

                it 'should increment progress bar without yielding' do
                  expect { |b|
                    target.each_changed(options, &b)
                  }.not_to yield_control

                  expect(progress_bar).to be_finished
                end
              end
            end

            context 'new module ancestors' do
              let(:existing_module_ancestors) do
                []
              end

              it 'should #increment progress bar' do
                each_changed

                expect(progress_bar).to be_finished
              end

              it 'should increment progress bar after yieldreturn' do
                expected_progress = 0

                target.each_changed(options) { |_|
                  expect(progress_bar.progress).to eq(expected_progress)
                  expected_progress += 1
                }

                expect(progress_bar.progress).to eq(expected_progress)
              end

              it 'should finish progress bar only after return' do
                target.each_changed(options) { |_|
                  expect(progress_bar).not_to be_finished
                }

                expect(progress_bar).to be_finished
              end
            end
          end

          context 'without progress bar' do
            it 'should set #total to #relative_paths #length' do
              expected_total = target.send(:relative_paths).length

              expect_any_instance_of(Metasploit::Cache::NullProgressBar).to receive(:total=).with(expected_total)

              each_changed
            end

            context 'updatable module ancestors' do
              let(:new_module_ancestors) do
                []
              end

              context 'with changed' do
                let(:options) do
                  super().merge(
                      assume_changed: true
                  )
                end

                it 'increments progress bar with yielding' do
                  expect_any_instance_of(Metasploit::Cache::NullProgressBar).to receive(:increment).exactly(existing_module_ancestors.length).times

                  actual_relative_paths = []

                  target.each_changed(options) { |module_ancestor|
                    actual_relative_paths << module_ancestor.relative_path
                  }

                  expect(actual_relative_paths).to match_array(existing_module_ancestor_relative_paths)
                end
              end

              context 'without changed' do
                let(:options) do
                  super().merge(
                      assume_changed: false
                  )
                end

                it 'increments progress bar without yielding' do
                  expect_any_instance_of(Metasploit::Cache::NullProgressBar).to receive(:increment).exactly(existing_module_ancestors.length).times

                  expect { |b|
                    target.each_changed(options, &b)
                  }.not_to yield_control
                end
              end
            end

            context 'new module ancestors' do
              let(:existing_module_ancestors) do
                []
              end

              it 'increments progress bar' do
                expect_any_instance_of(Metasploit::Cache::NullProgressBar).to receive(:increment).exactly(new_module_ancestor_relative_paths.length).times

                each_changed
              end
            end
          end
        end
      end

      context 'without block' do
        let(:block) do
          nil
        end

        it { should be_an Enumerator }
      end
    end

    context '#real_path_rule' do
      subject(:real_path_rule) do
        target.send(:real_path_rule)
      end

      it { is_expected.to be_a File::Find }

      context 'ftype' do
        subject(:ftype) {
          real_path_rule.ftype
        }

        it { is_expected.to eq('file') }
      end

      context '#path' do
        subject(:path) do
          real_path_rule.path
        end

        it 'should be Metasploit::Cache::Module::Path#real_path + relative_path_prefix' do
          expect(path).to eq(module_path.real_pathname.join(relative_path_prefix).to_path)
        end
      end

      context '#pattern' do
        subject(:pattern) do
          real_path_rule.pattern
        end

        it 'should be file with Metasploit::Cache::Module::Ancetor::EXTENSION' do
          expect(pattern).to eq("*#{Metasploit::Cache::Module::Ancestor::EXTENSION}")
        end
      end
    end

    context '#relative_paths' do
      subject(:relative_paths) do
        target.send(:relative_paths)
      end

      #
      # lets
      #

      let(:module_path) do
        FactoryGirl.create(:metasploit_cache_module_path)
      end

      #
      # let!s
      #

      let!(:existing_module_ancestors) do
        FactoryGirl.create_list(factory, 2, parent_path: module_path)
      end

      let!(:new_module_ancestors) do
        FactoryGirl.create_list(factory, 2, parent_path: module_path)
      end

      #
      # callbacks
      #

      before(:each) do
        2.times do |n|
          module_path.real_pathname.join("directory_#{n}").mkpath
        end

        2.times do |n|
          module_path.real_pathname.join("file_#{n}").open('wb') do |f|
            f.puts "File without extension #{n}"
          end
        end
      end

      it 'should not include directories' do
        expect(
            relative_paths.any? { |relative_path|
              module_path.real_pathname.join(relative_path).directory?
            }
        ).to eq(false)
      end

      it 'should only include files' do
        expect(
            relative_paths.all? { |relative_path|
              module_path.real_pathname.join(relative_path).file?
            }
        ).to eq(true)
      end

      it 'should only include file names with Metasploit::Cache::Module::Ancestor::EXTENSION' do
        expect(
            relative_paths.all? { |relative_path|
              module_path.real_pathname.join(relative_path).extname == Metasploit::Cache::Module::Ancestor::EXTENSION
            }
        ).to eq(true)
      end

      it 'should include all Metasploit::Cache::Module::Ancestor#real_paths' do
        expected_relative_paths = []
        expected_relative_paths.concat existing_module_ancestors.map(&:relative_path)
        expected_relative_paths.concat new_module_ancestors.map(&:relative_path)

        expect(relative_paths).to match_array(expected_relative_paths)
      end
    end
  end
end