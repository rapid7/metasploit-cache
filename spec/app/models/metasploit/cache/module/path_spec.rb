RSpec.describe Metasploit::Cache::Module::Path do
  it { should be_a ActiveModel::Dirty }

  it_should_behave_like 'Metasploit::Cache::RealPathname' do
    let(:base_instance) do
      FactoryGirl.build(:metasploit_cache_module_path)
    end
  end

  context 'associations' do
    it { should have_many(:module_ancestors).class_name('Metasploit::Cache::Module::Ancestor').dependent(:destroy).with_foreign_key(:parent_path_id) }
  end

  context 'callbacks' do
    context 'before_validation' do
      context 'nilify blanks' do
        let(:path) do
          FactoryGirl.build(
              :metasploit_cache_module_path,
              :gem => '',
              :name => ''
          )
        end

        it 'should have empty gem' do
          expect(path.gem).not_to be_nil
          expect(path.gem).to be_empty
        end

        it 'should have empty name' do
          expect(path.name).not_to be_nil
          expect(path.name).to be_empty
        end

        context 'after validation' do
          before(:each) do
            path.valid?
          end

          it 'does not have a gem' do
            expect(path.gem).to be_nil
          end

          it 'does not have a name' do
            expect(path.name).to be_nil
          end
        end
      end

      context '#normalize_real_path' do
        let(:parent_pathname) do
          Metasploit::Model::Spec.temporary_pathname.join('metasploit', 'cache', 'module', 'path')
        end

        let(:path) do
          FactoryGirl.build(
              :metasploit_cache_module_path,
              :real_path => symlink_pathname.to_path
          )
        end

        let(:real_basename) do
          'real'
        end

        let(:real_pathname) do
          parent_pathname.join(real_basename)
        end

        let(:symlink_basename) do
          'symlink'
        end

        let(:symlink_pathname) do
          parent_pathname.join(symlink_basename)
        end

        before(:each) do
          real_pathname.mkpath

          Dir.chdir(parent_pathname.to_path) do
            File.symlink(real_basename, 'symlink')
          end
        end

        it 'should convert real_path to a real path using File#real_path' do
          expected_real_path = Metasploit::Model::File.realpath(path.real_path)

          expect(path.real_path).not_to eq(expected_real_path)

          path.valid?

          expect(path.real_path).to eq(expected_real_path)
        end
      end
    end

    context 'after update' do
      context '#update_module_ancestor_real_paths' do
        context 'with change to #real_path' do
          let!(:path) do
            FactoryGirl.create(:metasploit_cache_module_path)
          end

          let(:new_real_path) do
            FactoryGirl.generate :metasploit_cache_module_path_real_path
          end

          context 'with #module_ancestors' do
            let!(:ancestors) do
              FactoryGirl.create_list(:metasploit_cache_module_ancestor, 2, :parent_path => path)
            end

            before(:each) do
              # Have to remove new_real_path as sequence will have already created it
              FileUtils.rmdir(new_real_path)
              # Move old real_path to new real_path to simulate install location for path changing and to ensure
              # that ancestors exist on path.
              FileUtils.mv(path.real_path, new_real_path)

              path.real_path = new_real_path
            end

            it 'should save without errors' do
              expect {
                path.save!
              }.to_not raise_error
            end

            it "should update ancestor's real_paths" do
              expect {
                path.save!
              }.to change {
                # true = reload association
                path.module_ancestors(true).map(&:real_path)
              }
            end
          end
        end
      end
    end
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:gem).of_type(:string).with_options(:null => true) }
      it { should have_db_column(:name).of_type(:string).with_options(:null => true) }
      it { should have_db_column(:real_path).of_type(:text).with_options(:null => false) }
    end

    context 'indices' do
      it { should have_db_index([:gem, :name]).unique(true) }
      it { should have_db_index(:real_path).unique(true) }
    end
  end

  context 'factories' do
    context :metasploit_cache_module_path do
      subject(:metasploit_cache_module_path) do
        FactoryGirl.build(:metasploit_cache_module_path)
      end

      it { should be_valid }
    end

    context :named_metasploit_cache_module_path do
      subject(:named_metasploit_cache_module_path) do
        FactoryGirl.build(:named_metasploit_cache_module_path)
      end

      it { should be_valid }

      it 'has a gem' do
        expect(named_metasploit_cache_module_path.gem).not_to be_nil
      end

      it 'has a name' do
        expect(named_metasploit_cache_module_path.name).not_to be_nil
      end
    end

    context :unnamed_metasploit_cache_module_path do
      subject(:unnamed_metasploit_cache_module_path) do
        FactoryGirl.build(:unnamed_metasploit_cache_module_path)
      end

      it { should be_valid }

      it 'does not have a gem' do
        expect(unnamed_metasploit_cache_module_path.gem).to be_nil
      end

      it 'does not have a name' do
        expect(unnamed_metasploit_cache_module_path.name).to be_nil
      end
    end
  end

  context 'mass assignment security' do
    it { should allow_mass_assignment_of(:gem) }
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:real_path) }
  end

  context 'validations' do
    context 'directory' do
      let(:error) do
        'must be a directory'
      end

      let(:path) do
        FactoryGirl.build(
            :metasploit_cache_module_path,
            :real_path => real_path
        )
      end

      before(:each) do
        path.valid?
      end

      context 'with #real_path' do
        context 'with directory' do
          let(:real_path) do
            FactoryGirl.generate :metasploit_cache_module_path_directory_real_path
          end

          it 'should not record error on real_path' do
            path.valid?

            expect(path.errors[:real_path]).not_to include(error)
          end
        end

        context 'with file' do
          let(:pathname) do
            Metasploit::Model::Spec.temporary_pathname.join(
                'metasploit',
                'cache',
                'module',
                'path',
                'real',
                'path',
                'file'
            )
          end

          let(:real_path) do
            pathname.to_path
          end

          before(:each) do
            Metasploit::Model::Spec::PathnameCollision.check!(pathname)

            pathname.parent.mkpath

            pathname.open('wb') do |f|
              f.puts 'A file'
            end
          end

          it 'should record error on real_path' do
            path.valid?

            expect(path.errors[:real_path]).to include(error)
          end
        end
      end

      context 'without #real_path' do
        let(:real_path) do
          nil
        end

        it 'should record error on real_path' do
          path.valid?

          expect(path.errors[:real_path]).to include(error)
        end
      end
    end

    context 'gem and name' do
      let(:gem_error) do
        "can't be blank if name is present"
      end

      let(:name_error) do
        "can't be blank if gem is present"
      end

      subject(:path) do
        FactoryGirl.build(
            :metasploit_cache_module_path,
            :gem => gem,
            :name => name
        )
      end

      before(:each) do
        path.valid?
      end

      context 'with gem' do
        let(:gem) do
          FactoryGirl.generate :metasploit_cache_module_path_gem
        end

        context 'with name' do
          let(:name) do
            FactoryGirl.generate :metasploit_cache_module_path_name
          end

          it 'should not record error on gem' do
            expect(path.errors[:gem]).not_to include(gem_error)
          end

          it 'should not record error on name' do
            expect(path.errors[:name]).not_to include(name_error)
          end
        end

        context 'without name' do
          let(:name) do
            nil
          end

          it 'should not record error on gem' do
            expect(path.errors[:gem]).not_to include(gem_error)
          end

          it 'should record error on name' do
            expect(path.errors[:name]).to include(name_error)
          end
        end
      end

      context 'without gem' do
        let(:gem) do
          nil
        end

        context 'with name' do
          let(:name) do
            FactoryGirl.generate :metasploit_cache_module_path_name
          end

          it 'should record error on gem' do
            expect(path.errors[:gem]).to include(gem_error)
          end

          it 'should not record error on name' do
            expect(path.errors[:name]).not_to include(name_error)
          end
        end

        context 'without name' do
          let(:name) do
            nil
          end

          it 'should not record error on gem' do
            expect(path.errors[:gem]).not_to include(gem_error)
          end

          it 'should not record error on name' do
            expect(path.errors[:name]).not_to include(name_error)
          end
        end
      end
    end

    context 'validate unique of name scoped to gem' do
      context 'with different real_paths' do
        #
        # lets
        #

        let(:duplicate) do
          FactoryGirl.build(
              :named_metasploit_cache_module_path,
              :gem => original.gem,
              :name => original.name
          )
        end

        #
        # let!s
        #

        # let! so it exists in database for duplicate to validate against
        let!(:original) do
          FactoryGirl.create(
              :named_metasploit_cache_module_path
          )
        end

        context 'with default validation context' do
          it 'validates uniqueness of name scoped to gem' do
            expect(duplicate).not_to be_valid
            expect(duplicate.errors[:name]).to include('has already been taken')
          end
        end

        context 'with :add validation context' do
          it 'skips validating uniqueness of name scoped to gem' do
            expect(duplicate).to be_valid(:add)
          end
        end
      end
    end

    context 'real_path' do
      #
      # lets
      #

      let(:duplicate) {
        FactoryGirl.build(:metasploit_cache_module_path, real_path: real_path)
      }

      let(:real_path) do
        FactoryGirl.generate :metasploit_cache_module_path_real_path
      end

      #
      # let!s
      #

      let!(:original) {
        FactoryGirl.create(:metasploit_cache_module_path, real_path: real_path)
      }

      context 'with default validation context' do
        it 'should validate uniqueness of real path' do
          expect(duplicate).not_to be_valid
          expect(duplicate.errors[:real_path]).to include('has already been taken')
        end
      end

      context 'with :add validation context' do
        it 'skips validating uniqueness of real path' do
          expect(duplicate).to be_valid(:add)
        end
      end
    end
  end

  context '#directory?' do
    subject(:directory?) do
      path.directory?
    end

    let(:path) do
      FactoryGirl.build(
          :metasploit_cache_module_path,
          :real_path => real_path
      )
    end

    context 'with #real_path' do
      context 'with file' do
        let(:pathname) do
          Metasploit::Model::Spec.temporary_pathname.join(
              'metasploit',
              'cache',
              'module',
              'path',
              'real',
              'path',
              'file'
          )
        end

        let(:real_path) do
          pathname.to_path
        end

        before(:each) do
          Metasploit::Model::Spec::PathnameCollision.check!(pathname)

          pathname.parent.mkpath

          pathname.open('wb') do |f|
            f.puts 'A file'
          end
        end


        it { is_expected.to eq(false) }
      end

      context 'with directory' do
        let(:real_path) do
          FactoryGirl.generate :metasploit_cache_module_path_directory_real_path
        end

        it { is_expected.to eq(true) }
      end
    end

    context 'without #real_path' do
      let(:real_path) do
        nil
      end

      it { is_expected.to eq(false) }
    end
  end

  context '#each_changed_module_ancestor' do
    subject(:each_changed_module_ancestor) do
      path.each_changed_module_ancestor(options, &block)
    end

    #
    # lets
    #

    let(:new_module_ancestors) do
      # makes file on disk, but not Metasploit::Cache::Module::Ancestor record in database
      FactoryGirl.build_list(
          :metasploit_cache_module_ancestor,
          2,
          parent_path: path
      )
    end

    let(:options) do
      {
          changed: true
      }
    end

    let(:path) do
      FactoryGirl.create(:metasploit_cache_module_path)
    end

    #
    # let!s
    #

    let!(:existing_module_ancestors) do
      FactoryGirl.create_list(
          :metasploit_cache_module_ancestor,
          2,
          parent_path: path
      )
    end


    before(:each) do
      # validate to derive real_path
      new_module_ancestors.each(&:valid?)
    end

    context 'with block' do
      let(:block) do
        lambda { |module_ancestor|
        }
      end

      let(:existing_module_ancestor_real_paths) do
        existing_module_ancestors.map(&:real_path)
      end

      let(:module_ancestor_real_paths) do
        existing_module_ancestor_real_paths + new_module_ancestor_real_paths
      end

      let(:new_module_ancestor_real_paths) do
        new_module_ancestors.map(&:derived_real_path)
      end

      it 'use #module_ancestor_real_paths to gather Metasploit::Cache::Module::Ancestor#real_path' do
        expect(path).to receive(:module_ancestor_real_paths).and_return([])

        each_changed_module_ancestor
      end

      it 'call ActiveRecord::Base.connection_pool.with_connection around database accesses' do
        expect(ActiveRecord::Base.connection_pool).to receive(:with_connection) do |&block|
          new = double('ActiveRecord::Association#new')
          where_relation = double('ActiveRecord::Relation#where', find_each: nil)
          module_ancestors = double(
              'Metasploit::Cache::Module::Path#module_ancestor',
              new: new,
              where: where_relation
          )
          with_connection = double('With Connection', module_ancestors: module_ancestors)

          with_connection.instance_eval(&block)
        end

        each_changed_module_ancestor
      end

      it 'uses one query to find all updatable Metasploit::Cache::Module::Ancestors' do
        expect(path.module_ancestors).to receive(
                                             :where
                                         ).with(
                                             hash_including(
                                                 real_path: module_ancestor_real_paths
                                             )
                                         ).and_call_original

        each_changed_module_ancestor
      end

      it 'should use Set to calculate new real_paths' do
        set = Set.new(module_ancestor_real_paths)

        expect(Set).to receive(:new) { |actual_real_paths|
          expect(actual_real_paths).to match_array(module_ancestor_real_paths)
        }.and_return(set)

        existing_module_ancestor_real_paths.each do |real_path|
          expect(set).to receive(:delete).with(real_path).and_call_original
        end

        each_changed_module_ancestor
      end

      it 'should only fetch :changed and get :progress_bar option once as a loop optimization' do
        expect(options).to receive(:fetch).with(:changed, false)
        expect(options).to receive(:[]).with(:progress_bar)

        each_changed_module_ancestor
      end

      context ':changed option' do
        context 'with true' do
          let(:options) do
            {
                changed: true
            }
          end

          it 'should yield existing and new Metasploit::Cache::Module::Ancestors' do
            changed_module_ancestors = path.each_changed_module_ancestor(options)

            existing_module_ancestors.each do |existing_module_ancestor|
              expect(changed_module_ancestors).to include(existing_module_ancestor)
            end

            actual_real_paths = changed_module_ancestors.map(&:real_path)

            new_module_ancestor_real_paths.each do |real_path|
              expect(actual_real_paths).to include(real_path)
            end
          end
        end

        context 'with false' do
          subject(:changed_module_ancestors) do
            path.each_changed_module_ancestor(options).to_a
          end

          let(:options) do
            {
                changed: false
            }
          end

          context 'without change to file modification time' do
            it 'should yield only new Metasploit::Cache::Module::Ancestors' do
              actual_real_paths = changed_module_ancestors.map(&:real_path)

              expect(
                  changed_module_ancestors.all? { |module_ancestor|
                    module_ancestor.new_record?
                  }
              ).to eq(true)

              expect(actual_real_paths).to match_array(new_module_ancestor_real_paths)
            end
          end

          context 'with change to file modification time' do
            def change_real_path_modification_time(module_ancestor)
              changed_time_with_zone = module_ancestor.real_path_modified_at + 5.seconds
              changed_time = changed_time_with_zone.time()
              File.utime(changed_time, changed_time, module_ancestor.real_path)
            end

            context 'with change to file contents' do
              def change_contents(module_ancestor)
                File.open(module_ancestor.real_path, 'a') do |f|
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
                actual_real_paths = changed_module_ancestors.map(&:real_path)

                existing_module_ancestors.each do |existing_module_ancestor|
                  expect(actual_real_paths).to include(existing_module_ancestor.real_path)
                end

                new_module_ancestors.each do |new_module_ancestor|
                  expect(actual_real_paths).to include(new_module_ancestor.real_path)
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

          it 'should set #total to #module_ancestor_real_paths #length' do
            expected_total = path.module_ancestor_real_paths.length

            expect(progress_bar).to receive(:total=).with(expected_total).and_call_original

            each_changed_module_ancestor
          end

          context 'updatable module ancestors' do
            let(:new_module_ancestors) do
              []
            end

            context 'with changed' do
              let(:options) do
                super().merge(
                    changed: true
                )
              end

              it 'should increment progress bar with yielding' do
                actual_real_paths = []

                path.each_changed_module_ancestor(options) { |module_ancestor|
                  actual_real_paths << module_ancestor.real_path
                }

                expect(actual_real_paths).to match_array(existing_module_ancestor_real_paths)
                expect(progress_bar).to be_finished
              end

              it 'should increment progress bar after yieldreturn' do
                expected_progress = 0

                path.each_changed_module_ancestor(options) { |_|
                  expect(progress_bar.progress).to eq(expected_progress)
                  expected_progress += 1
                }
                expect(progress_bar.progress).to eq(expected_progress)
              end
            end

            context 'without changed' do
              let(:options) do
                super().merge(
                    changed: false
                )
              end

              it 'should increment progress bar without yielding' do
                expect { |b|
                  path.each_changed_module_ancestor(options, &b)
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
              each_changed_module_ancestor

              expect(progress_bar).to be_finished
            end

            it 'should increment progress bar after yieldreturn' do
              expected_progress = 0

              path.each_changed_module_ancestor(options) { |_|
                expect(progress_bar.progress).to eq(expected_progress)
                expected_progress += 1
              }

              expect(progress_bar.progress).to eq(expected_progress)
            end

            it 'should finish progress bar only after return' do
              path.each_changed_module_ancestor(options) { |_|
                expect(progress_bar).not_to be_finished
              }

              expect(progress_bar).to be_finished
            end
          end
        end

        context 'without progress bar' do
          it 'should set #total to #module_ancestor_real_paths #length' do
            expected_total = path.module_ancestor_real_paths.length

            expect_any_instance_of(Metasploit::Cache::NullProgressBar).to receive(:total=).with(expected_total)

            each_changed_module_ancestor
          end

          context 'updatable module ancestors' do
            let(:new_module_ancestors) do
              []
            end

            context 'with changed' do
              let(:options) do
                super().merge(
                    changed: true
                )
              end

              it 'increments progress bar with yielding' do
                expect_any_instance_of(Metasploit::Cache::NullProgressBar).to receive(:increment).exactly(existing_module_ancestors.length).times

                actual_real_paths = []

                path.each_changed_module_ancestor(options) { |module_ancestor|
                  actual_real_paths << module_ancestor.real_path
                }

                expect(actual_real_paths).to match_array(existing_module_ancestor_real_paths)
              end
            end

            context 'without changed' do
              let(:options) do
                super().merge(
                    changed: false
                )
              end

              it 'increments progress bar without yielding' do
                expect_any_instance_of(Metasploit::Cache::NullProgressBar).to receive(:increment).exactly(existing_module_ancestors.length).times

                expect { |b|
                  path.each_changed_module_ancestor(options, &b)
                }.not_to yield_control
              end
            end
          end

          context 'new module ancestors' do
            let(:existing_module_ancestors) do
              []
            end

            it 'increments progress bar' do
              expect_any_instance_of(Metasploit::Cache::NullProgressBar).to receive(:increment).exactly(new_module_ancestor_real_paths.length).times

              each_changed_module_ancestor
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

  context '#module_ancestor_real_paths' do
    subject(:module_ancestor_real_paths) do
      module_path.module_ancestor_real_paths
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
      FactoryGirl.create_list(
          :metasploit_cache_module_ancestor,
          2,
          parent_path: module_path
      )
    end

    let!(:new_module_ancestors) do
      FactoryGirl.create_list(
          :metasploit_cache_module_ancestor,
          2,
          parent_path: module_path
      )
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

    it 'uses #module_ancestor_rule to find Metasploit::Cache::Module::Ancestor#real_paths' do
      expect(module_path).to receive(:module_ancestor_rule).and_call_original

      module_ancestor_real_paths
    end

    it 'should not include directories' do
      expect(
          module_ancestor_real_paths.any? { |real_path|
            File.directory?(real_path)
          }
      ).to eq(false)
    end

    it 'should only include files' do
      expect(
          module_ancestor_real_paths.all? { |real_path|
            File.file?(real_path)
          }
      ).to eq(true)
    end

    it 'should only include file names with Metasploit::Cache::Module::Ancestor::EXTENSION' do
      expect(
          module_ancestor_real_paths.all? { |real_path|
            File.extname(real_path) == Metasploit::Cache::Module::Ancestor::EXTENSION
          }
      ).to eq(true)
    end

    it 'should include all Metasploit::Cache::Module::Ancestor#real_paths' do
      expected_real_paths = []
      expected_real_paths.concat existing_module_ancestors.map(&:real_path)
      expected_real_paths.concat new_module_ancestors.map(&:derived_real_path)

      expect(module_ancestor_real_paths).to match_array(expected_real_paths)
    end
  end

  context '#module_ancestor_rule' do
    subject(:module_ancestor_rule) do
      module_path.module_ancestor_rule
    end

    let(:module_path) do
      FactoryGirl.create(:metasploit_cache_module_path)
    end

    it { should be_a File::Find }

    context 'ftype' do
      subject(:ftype) {
        module_ancestor_rule.ftype
      }

      it { is_expected.to eq('file') }
    end

    context '#path' do
      subject(:path) do
        module_ancestor_rule.path
      end

      it 'should be Metasploit::Cache::Module::Path#real_path' do
        expect(path).to eq(module_path.real_path)
      end
    end

    context '#pattern' do
      subject(:pattern) do
        module_ancestor_rule.pattern
      end

      it 'should be file with Metasploit::Cache::Module::Ancetor::EXTENSION' do
        expect(pattern).to eq("*#{Metasploit::Cache::Module::Ancestor::EXTENSION}")
      end
    end
  end

  context '#named?' do
    subject(:named?) do
      path.named?
    end

    let(:path) do
      FactoryGirl.build(
          :metasploit_cache_module_path,
          :gem => gem,
          :name => name
      )
    end

    context 'with blank gem' do
      let(:gem) do
        ''
      end

      context 'with blank name' do
        let(:name) do
          ''
        end

        it { is_expected.to eq(false) }
      end

      context 'without blank name' do
        let(:name) do
          FactoryGirl.generate :metasploit_cache_module_path_name
        end

        it { is_expected.to eq(false) }
      end
    end

    context 'without blank gem' do
      let(:gem) do
        FactoryGirl.generate :metasploit_cache_module_path_gem
      end

      context 'with blank name' do
        let(:name) do
          ''
        end

        it { is_expected.to eq(false) }
      end

      context 'without blank name' do
        let(:name) do
          FactoryGirl.generate :metasploit_cache_module_path_name
        end

        it { is_expected.to eq(true) }
      end
    end
  end

  context '#name_collision' do
    subject(:name_collision) do
      path.name_collision
    end

    let!(:collision) do
      FactoryGirl.create(:named_metasploit_cache_module_path)
    end

    let!(:other_named) do
      FactoryGirl.create(:named_metasploit_cache_module_path)
    end

    let!(:unnamed) do
      FactoryGirl.create(:unnamed_metasploit_cache_module_path)
    end

    before(:each) do
      path.valid?
    end

    context 'with named' do
      context 'with same (gem, name)' do
        let(:path) do
          FactoryGirl.build(
              :named_metasploit_cache_module_path,
              :gem => collision.gem,
              :name => collision.name
          )
        end

        it 'should return collision' do
          expect(name_collision).to eq(collision)
        end
      end

      context 'without same (gem, name)' do
        let(:path) do
          FactoryGirl.build(:named_metasploit_cache_module_path)
        end

        it { should be_nil }
      end
    end

    context 'without named' do
      let(:path) do
        FactoryGirl.build(:unnamed_metasploit_cache_module_path)
      end

      it { should be_nil }
    end
  end

  context '#real_path_collision' do
    subject(:real_path_collision) do
      path.real_path_collision
    end

    let!(:collision) do
      FactoryGirl.create(:metasploit_cache_module_path)
    end

    context 'with same real_path' do
      let(:path) do
        FactoryGirl.build(:metasploit_cache_module_path, :real_path => collision.real_path)
      end

      it 'should return collision' do
        expect(real_path_collision).to eq(collision)
      end
    end

    context 'without same real_path' do
      let(:path) do
        FactoryGirl.build(:metasploit_cache_module_path)
      end

      it { should be_nil }
    end
  end

  context '#was_named?' do
    subject(:was_named?) do
      path.was_named?
    end

    let(:gem) do
      FactoryGirl.generate :metasploit_cache_module_path_gem
    end

    let(:name) do
      FactoryGirl.generate :metasploit_cache_module_path_name
    end

    let(:path) do
      FactoryGirl.build(
          :metasploit_cache_module_path
      )
    end

    before(:each) do
      path.gem = gem_was
      path.name = name_was

      path.changed_attributes.clear

      path.gem = gem
      path.name = name
    end

    context 'with blank gem_was' do
      let(:gem_was) do
        nil
      end

      context 'with blank name_was' do
        let(:name_was) do
          nil
        end

        it { is_expected.to eq(false) }
      end

      context 'without blank name_was' do
        let(:name_was) do
          FactoryGirl.generate :metasploit_cache_module_path_name
        end

        it { is_expected.to eq(false) }
      end
    end

    context 'without blank gem_was' do
      let(:gem_was) do
        FactoryGirl.generate :metasploit_cache_module_path_gem
      end

      context 'with blank name_was' do
        let(:name_was) do
          nil
        end

        it { is_expected.to eq(false) }
      end

      context 'without blank name_was' do
        let(:name_was) do
          FactoryGirl.generate :metasploit_cache_module_path_name
        end

        it { is_expected.to eq(true) }
      end
    end
  end
end