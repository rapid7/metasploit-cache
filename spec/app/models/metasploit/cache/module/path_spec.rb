RSpec.describe Metasploit::Cache::Module::Path do
  it { should be_a ActiveModel::Dirty }

  it_should_behave_like 'Metasploit::Cache::Module::Path::AssociationExtension',
                        association: :auxiliary_ancestors,
                        factory: :metasploit_cache_auxiliary_ancestor,
                        relative_path_prefix: 'auxiliary'

  it_should_behave_like 'Metasploit::Cache::Module::Path::AssociationExtension',
                        association: :encoder_ancestors,
                        factory: :metasploit_cache_encoder_ancestor,
                        relative_path_prefix: 'encoders'

  it_should_behave_like 'Metasploit::Cache::Module::Path::AssociationExtension',
                        association: :exploit_ancestors,
                        factory: :metasploit_cache_exploit_ancestor,
                        relative_path_prefix: 'exploits'

  it_should_behave_like 'Metasploit::Cache::Module::Path::AssociationExtension',
                        association: :nop_ancestors,
                        factory: :metasploit_cache_nop_ancestor,
                        relative_path_prefix: 'nops'

  it_should_behave_like 'Metasploit::Cache::Module::Path::AssociationExtension',
                        association: :single_payload_ancestors,
                        factory: :metasploit_cache_payload_single_ancestor,
                        relative_path_prefix: 'payloads/singles'

  it_should_behave_like 'Metasploit::Cache::Module::Path::AssociationExtension',
                        association: :stage_payload_ancestors,
                        factory: :metasploit_cache_payload_stage_ancestor,
                        relative_path_prefix: 'payloads/stages'

  it_should_behave_like 'Metasploit::Cache::Module::Path::AssociationExtension',
                        association: :stager_payload_ancestors,
                        factory: :metasploit_cache_payload_stager_ancestor,
                        relative_path_prefix: 'payloads/stagers'

  it_should_behave_like 'Metasploit::Cache::Module::Path::AssociationExtension',
                        association: :post_ancestors,
                        factory: :metasploit_cache_post_ancestor,
                        relative_path_prefix: 'post'

  it_should_behave_like 'Metasploit::Cache::RealPathname' do
    let(:base_instance) do
      FactoryGirl.build(:metasploit_cache_module_path)
    end
  end

  context 'associations' do
    it { is_expected.to have_many(:auxiliary_ancestors).class_name('Metasploit::Cache::Auxiliary::Ancestor').dependent(:destroy).with_foreign_key(:parent_path_id) }
    it { is_expected.to have_many(:encoder_ancestors).class_name('Metasploit::Cache::Encoder::Ancestor').dependent(:destroy).with_foreign_key(:parent_path_id) }
    it { is_expected.to have_many(:exploit_ancestors).class_name('Metasploit::Cache::Exploit::Ancestor').dependent(:destroy).with_foreign_key(:parent_path_id) }
    it { is_expected.to have_many(:nop_ancestors).class_name('Metasploit::Cache::Nop::Ancestor').dependent(:destroy).with_foreign_key(:parent_path_id) }
    it { is_expected.to have_many(:single_payload_ancestors).class_name('Metasploit::Cache::Payload::Single::Ancestor').dependent(:destroy).with_foreign_key(:parent_path_id) }
    it { is_expected.to have_many(:stage_payload_ancestors).class_name('Metasploit::Cache::Payload::Stage::Ancestor').dependent(:destroy).with_foreign_key(:parent_path_id) }
    it { is_expected.to have_many(:stager_payload_ancestors).class_name('Metasploit::Cache::Payload::Stager::Ancestor').dependent(:destroy).with_foreign_key(:parent_path_id) }
    it { is_expected.to have_many(:post_ancestors).class_name('Metasploit::Cache::Post::Ancestor').dependent(:destroy).with_foreign_key(:parent_path_id) }
  end

  context 'callbacks' do
    context 'before_validation' do
      context 'nilify blanks' do
        let(:path) do
          FactoryGirl.build(
              :metasploit_cache_module_path,
              gem: '',
              name: ''
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
              real_path: symlink_pathname.to_path
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
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:gem).of_type(:string).with_options(null: true) }
      it { should have_db_column(:name).of_type(:string).with_options(null: true) }
      it { should have_db_column(:real_path).of_type(:text).with_options(null: false) }
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

  context 'validations' do
    context 'directory' do
      let(:error) do
        'must be a directory'
      end

      let(:path) do
        FactoryGirl.build(
            :metasploit_cache_module_path,
            real_path: real_path
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
            gem: gem,
            name: name
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
              gem: original.gem,
              name: original.name
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
          let(:error) {
            I18n.translate!('errors.messages.taken')
          }

          it 'validates uniqueness of name scoped to gem' do
            expect(duplicate).not_to be_valid
            expect(duplicate.errors[:name]).to include(error)
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
        let(:error) {
          I18n.translate!('errors.messages.taken')
        }

        it 'should validate uniqueness of real path' do
          expect(duplicate).not_to be_valid
          expect(duplicate.errors[:real_path]).to include(error)
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
          real_path: real_path
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

  context '#named?' do
    subject(:named?) do
      path.named?
    end

    let(:path) do
      FactoryGirl.build(
          :metasploit_cache_module_path,
          gem: gem,
          name: name
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
              gem: collision.gem,
              name: collision.name
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
        FactoryGirl.build(:metasploit_cache_module_path, real_path: collision.real_path)
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