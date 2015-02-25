RSpec.describe Metasploit::Cache::Module::Ancestor, type: :model do
  subject(:module_ancestor) {
    FactoryGirl.build(:metasploit_cache_module_ancestor)
  }

  it_should_behave_like 'Metasploit::Cache::RealPathname' do
    let(:base_instance) do
      FactoryGirl.build(:metasploit_cache_module_ancestor)
    end
  end

  context 'CONSTANTS' do
    context 'DIRECTORY_BY_MODULE_TYPE' do
      subject(:directory_by_module_type) do
        described_class::DIRECTORY_BY_MODULE_TYPE
      end

      it "maps 'auxiliary' to 'auxiliary'" do
        expect(directory_by_module_type['auxiliary']).to eq('auxiliary')
      end

      it "maps 'encoder' to 'encoders'" do
        expect(directory_by_module_type['encoder']).to eq('encoders')
      end

      it "maps 'exploit' to 'exploits'" do
        expect(directory_by_module_type['exploit']).to eq('exploits')
      end

      it "maps 'nop' to 'nops'" do
        expect(directory_by_module_type['nop']).to eq('nops')
      end

      it "maps 'payloads' to 'payloadss'" do
        expect(directory_by_module_type['payload']).to eq('payloads')
      end

      it "maps 'post' to 'post'" do
        expect(directory_by_module_type['post']).to eq('post')
      end

      it 'should have same module types as Metasploit::Cache::Module::Type::ALL' do
        expect(directory_by_module_type.keys).to match_array(Metasploit::Cache::Module::Type::ALL)
      end
    end

    context 'EXTENSION' do
      subject(:extension) do
        described_class::EXTENSION
      end

      it 'should be ruby source extension' do
        expect(extension).to eq('.rb')
      end

      it "should start with '.'" do
        expect(extension).to start_with('.')
      end
    end

    context 'MODULE_TYPE_BY_DIRECTORY' do
      subject(:module_type_by_directory) do
        described_class::MODULE_TYPE_BY_DIRECTORY
      end

      it 'should have same module types as Metasploit::Cache::Module::Type::ALL' do
        expect(module_type_by_directory.values).to match_array(Metasploit::Cache::Module::Type::ALL)
      end

      it "maps 'auxiliary' to 'auxiliary'" do
        expect(module_type_by_directory['auxiliary']).to eq('auxiliary')
      end

      it "maps 'encoders' to 'encoder'" do
        expect(module_type_by_directory['encoders']).to eq('encoder')
      end

      it "maps 'exploits' to 'exploit'" do
        expect(module_type_by_directory['exploits']).to eq('exploit')
      end

      it "maps 'nops' to 'nop'" do
        expect(module_type_by_directory['nops']).to eq('nop')
      end

      it "maps 'payloads' to 'encoder'" do
        expect(module_type_by_directory['encoders']).to eq('encoder')
      end

      it "maps 'auxiliary' to 'auxiliary'" do
        expect(module_type_by_directory['auxiliary']).to eq('auxiliary')
      end

      it 'should have same module types as Metasploit::Cache::Module::Type::ALL' do
        expect(module_type_by_directory.values).to match_array(Metasploit::Cache::Module::Type::ALL)
      end
    end

    # pattern is tested in validation tests below
    it 'should define REFERENCE_NAME_REGEXP' do
      expect(described_class::REFERENCE_NAME_REGEXP).to be_a Regexp
    end

    context 'REFERENCE_NAME_SEPARATOR' do
      subject(:reference_name_separator) do
        described_class::REFERENCE_NAME_SEPARATOR
      end

      it { should == '/' }
    end

    # pattern is tested in validation tests below
    it 'should define SHA_HEX_DIGEST_REGEXP' do
      expect(described_class::SHA1_HEX_DIGEST_REGEXP).to be_a Regexp
    end
  end

  context 'associations' do
    it { should have_many(:descendants).class_name('Metasploit::Cache::Module::Class').through(:relationships) }
    it { should belong_to(:parent_path).class_name('Metasploit::Cache::Module::Path') }
    it { should have_many(:relationships).class_name('Metasploit::Cache::Module::Relationship').dependent(:destroy) }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:module_type).of_type(:string).with_options(:null => false) }
      it { should have_db_column(:real_path).of_type(:text).with_options(:null => false) }
      it { should have_db_column(:real_path_modified_at).of_type(:datetime).with_options(:null => false) }
      it { should have_db_column(:real_path_sha1_hex_digest).of_type(:string).with_options(:limit => 40, :null => false) }
      it { should have_db_column(:reference_name).of_type(:text).with_options(:null => false) }
    end

    context 'indices' do
      context 'foreign key' do
        it { should have_db_index(:parent_path_id) }
      end

      context 'unique' do
        subject(:ancestor) do
          described_class.new
        end

        it 'should have unique index on (module_type, reference_name) to present that Msf::ModuleSet and Msf::PayloadSet only allow one module with a given reference_name' do
          expect(ancestor).to have_db_index([:module_type, :reference_name]).unique(true)
        end

        it 'should have unique index on real_path because only one file can have a given path' do
          expect(ancestor).to have_db_index(:real_path).unique(true)
        end

        it 'should have unique index on real_path_sha1_hex_digest so renames can be detected' do
          expect(ancestor).to have_db_index(:real_path_sha1_hex_digest).unique(true)
        end
      end
    end
  end

  context 'derivation' do
    include_context 'ActiveRecord attribute_type'

    let(:base_class) {
      Metasploit::Cache::Module::Ancestor
    }

    it_should_behave_like 'derives', :real_path, :validates => true

    context 'with only module_path and real_path' do
      subject(:module_ancestor) do
        # make sure real_path is derived
        expect(real_path_creator).to be_valid

        module_ancestor = described_class.new

        # work-around mass-assignment security
        module_ancestor.parent_path = real_path_creator.parent_path
        module_ancestor.real_path = real_path_creator.real_path

        module_ancestor
      end

      before(:each) do
        # run before validation callbacks to trigger derivations
        module_ancestor.valid?
      end

      context 'with payload' do
        let(:real_path_creator) do
          FactoryGirl.build(
              :metasploit_cache_module_ancestor,
              module_type: 'payload',
              payload_type: payload_type
          )
        end

        context 'with single' do
          let(:payload_type) do
            'single'
          end

          it { should be_valid }

          it 'should be valid for loading' do
            module_ancestor.valid?(:loading)
          end
        end
      end

      context 'without payload' do
        let(:real_path_creator) do
          FactoryGirl.build(
              :metasploit_cache_module_ancestor,
              module_type: module_type
          )
        end

        let(:module_type) do
          FactoryGirl.generate :metasploit_cache_non_payload_module_type
        end

        it { should be_valid }

        it 'should be valid for loading' do
          module_ancestor.valid?(:loading)
        end
      end
    end

    context 'with real_path' do
      before(:each) do
        # {Metasploit::Cache::Module::Ancestor#derived_real_path_modified_at} and
        # {Metasploit::Cache::Module::Ancestor#derived_real_path_sha1_hex_digest} both depend on real_path being
        # populated or they will return nil, so need set real_path = derived_real_path before testing as would happen
        # with the normal order of before validation callbacks.
        module_ancestor.real_path = module_ancestor.derived_real_path

        # blank out {Metasploit::Cache::Module::Ancestor#module_type} and
        # {Metasploit::Cache::Module::Ancestor#reference_name} so they will be rederived from
        # {Metasploit::Cache::Module::Ancestor#real_path} to simulate module cache construction usage.
        module_ancestor.module_type = nil
        module_ancestor.reference_name = nil
      end

      it_should_behave_like 'derives', :module_type, :validates => false
      it_should_behave_like 'derives', :real_path_modified_at, :validates => false
      it_should_behave_like 'derives', :real_path_sha1_hex_digest, :validates => false
      it_should_behave_like 'derives', :reference_name, :validates => false
    end
  end

  context 'factories' do
    context 'metasploit_cache_module_ancestor' do
      subject(:metasploit_cache_module_ancestor) do
        FactoryGirl.build(:metasploit_cache_module_ancestor)
      end

      it { should be_valid }

      context 'contents' do
        include_context 'Metasploit::Cache::Module::Ancestor factory contents'

        let(:module_ancestor) do
          metasploit_cache_module_ancestor
        end

        context 'metasploit_module' do
          include_context 'Metasploit::Cache::Module::Ancestor factory contents metasploit_module'

          # Classes are Modules, so this checks that it is either a Class or a Module.
          it { should be_a Module }

          context '#module_type' do
            let(:module_ancestor) do
              FactoryGirl.build(
                  :metasploit_cache_module_ancestor,
                  module_type: module_type
              )
            end

            context 'with payload' do
              let(:module_type) do
                Metasploit::Cache::Module::Type::PAYLOAD
              end

              it { should_not be_a Class }

              it 'should define #initalize that takes an option hash' do
                unbound_method = metasploit_module.instance_method(:initialize)

                expect(unbound_method.parameters.length).to eq(1)
                expect(unbound_method.parameters[0][0]).to eq(:opt)
              end
            end

            context 'without payload' do
              let(:module_type) do
                FactoryGirl.generate :metasploit_cache_non_payload_module_type
              end

              it { should be_a Class }

              context '#initialize' do
                subject(:instance) do
                  metasploit_module.new(attributes)
                end

                context 'with :framework' do
                  let(:attributes) do
                    {
                        framework: framework
                    }
                  end

                  let(:framework) do
                    double('Msf::Framework')
                  end

                  it 'should set #framework' do
                    expect(instance.framework).to eq(framework)
                  end
                end
              end
            end
          end
        end
      end
    end

    context :payload_metasploit_cache_module_ancestor do
      subject(:payload_metasploit_cache_module_ancestor) do
        FactoryGirl.build(:payload_metasploit_cache_module_ancestor)
      end

      it { should be_valid }

      it_should_behave_like 'Metasploit::Cache::Module::Ancestor payload factory' do
        let(:module_ancestor) do
          payload_metasploit_cache_module_ancestor
        end
      end
    end

    context :single_payload_metasploit_cache_module_ancestor do
      subject(:single_payload_metasploit_cache_module_ancestor) do
        FactoryGirl.build(:single_payload_metasploit_cache_module_ancestor)
      end

      it { should be_valid }

      it_should_behave_like 'Metasploit::Cache::Module::Ancestor payload factory' do
        let(:module_ancestor) do
          single_payload_metasploit_cache_module_ancestor
        end
      end
    end
  end

  context 'mass assignment security' do
    it 'should not allow mass assignment of full_name since it must match derived_full_name' do
      expect(module_ancestor).not_to allow_mass_assignment_of(:full_name)
    end

    it { should allow_mass_assignment_of(:module_type) }

    it 'should not allow mass assignment of payload_type since it must match derived_payload_type' do
      expect(module_ancestor).not_to allow_mass_assignment_of(:payload_type)
    end

    it 'should allow mass assignment of real_path to allow derivation of module_type and reference_name' do
      expect(module_ancestor).to allow_mass_assignment_of(:real_path)
    end

    it 'should not allow mass assignment of real_path_modified_at since it is derived' do
      expect(module_ancestor).not_to allow_mass_assignment_of(:real_path_modified_at)
    end

    it 'should not allow mass assignment of real_path_sha1_hex_digest since it is derived' do
      expect(module_ancestor).not_to allow_mass_assignment_of(:real_path_sha1_hex_digest)
    end

    it { should_not allow_mass_assignment_of(:parent_path_id) }
  end

  context 'validations' do
    subject(:module_ancestor) do
      # Don't use factory so that nil values can be tested without the nil being replaced with derived value
      described_class.new
    end

    let(:taken_error) do
      I18n.translate!('metasploit.model.errors.messages.taken')
    end

    it { should validate_inclusion_of(:module_type).in_array(Metasploit::Cache::Module::Type::ALL) }
    it { should validate_presence_of(:parent_path) }
    it { should validate_presence_of(:real_path_modified_at) }

    context 'real_path' do
      context 'validate uniqueness' do
        let!(:original_ancestor) do
          FactoryGirl.create(:metasploit_cache_module_ancestor)
        end

        context 'with same real_path' do
          subject(:same_real_path_ancestor) do
            # Don't use factory as it will try to write real_path, which cause a path collision
            original_ancestor.parent_path.module_ancestors.new(
                real_path: original_ancestor.real_path
            )
          end

          context 'with batched' do
            include_context 'Metasploit::Cache::Batch.batch'

            it 'should not add error on #real_path' do
              same_real_path_ancestor.valid?

              expect(same_real_path_ancestor.errors[:real_path]).not_to include(taken_error)
            end

            it 'should raise ActiveRecord::RecordNotUnique when saved' do
              expect {
                same_real_path_ancestor.save
              }.to raise_error(ActiveRecord::RecordNotUnique)
            end
          end

          context 'without batched' do
            it 'should add error on #real_path' do
              same_real_path_ancestor.valid?

              expect(same_real_path_ancestor.errors[:real_path]).to include(taken_error)
            end
          end
        end
      end
    end

    context 'real_path_sha1_hex_digest' do
      context 'validates format with SHA1_HEX_DIGEST_REGEXP' do
        let(:hexdigest) do
          Digest::SHA1.hexdigest('')
        end

        it 'should allow a Digest::SHA1.hexdigest' do
          expect(module_ancestor).to allow_value(hexdigest).for(:real_path_sha1_hex_digest)
        end

        it 'should not allow a truncated Digest::SHA1.hexdigest' do
          expect(module_ancestor).not_to allow_value(hexdigest[0, 39]).for(:real_path_sha1_hex_digest)
        end

        it 'should not allow upper case hex to maintain normalization' do
          expect(module_ancestor).not_to allow_value(hexdigest.upcase).for(:real_path_sha1_hex_digest)
        end

        it { should_not allow_value(nil).for(:real_path_sha1_hex_digest) }
      end

      context 'validates uniqueness' do
        let!(:original_ancestor) do
          FactoryGirl.create(:metasploit_cache_module_ancestor)
        end

        context 'with same real_path_sha1_hex_digest' do
          subject(:same_real_path_sha1_hex_digest_ancestor) do
            FactoryGirl.build(
                :metasploit_cache_module_ancestor,
                # real_path_sha1_hex_digest is derived, but not validated (as it would take too long)
                # so it can just be set directly
                :real_path_sha1_hex_digest => original_ancestor.real_path_sha1_hex_digest
            )
          end

          context 'with batched' do
            include_context 'Metasploit::Cache::Batch.batch'

            it 'should not add error on #real_path_sha1_hex_digest' do
              same_real_path_sha1_hex_digest_ancestor.valid?

              expect(same_real_path_sha1_hex_digest_ancestor.errors[:real_path_sha1_hex_digest]).not_to include(taken_error)
            end

            it 'should raise ActiveRecord::RecordNotUnique when saved' do
              expect {
                same_real_path_sha1_hex_digest_ancestor.save
              }.to raise_error(ActiveRecord::RecordNotUnique)
            end
          end

          context 'without batched' do
            it 'should add error on #real_path_sha1_hex_digest' do
              same_real_path_sha1_hex_digest_ancestor.valid?

              expect(same_real_path_sha1_hex_digest_ancestor.errors[:real_path_sha1_hex_digest]).to include(taken_error)
            end
          end
        end
      end
    end

    context 'reference_name' do
      context 'validates format with REFERENCE_NAME_REGEXP' do
        context 'without slashes' do
          context 'first character' do
            it 'should not allow space' do
              expect(module_ancestor).not_to allow_value(' ').for(:reference_name)
            end

            it 'should allow dash' do
              expect(module_ancestor).to allow_value('-').for(:reference_name)
            end

            it 'should allow digit' do
              expect(module_ancestor).to allow_value('0').for(:reference_name)
            end

            it 'should allow uppercase letter' do
              expect(module_ancestor).to allow_value('A').for(:reference_name)
            end

            it 'should allow underscore' do
              expect(module_ancestor).to allow_value('_').for(:reference_name)
            end

            it 'should allow lowercase letter' do
              expect(module_ancestor).to allow_value('a').for(:reference_name)
            end
          end

          context 'later letters' do
            let(:lowercase_letters) do
              ('a'..'z').to_a
            end

            let(:first_letter) do
              lowercase_letters.sample
            end

            it 'should not allow space' do
              expect(module_ancestor).not_to allow_value("#{first_letter} ").for(:reference_name)
            end

            it 'should allow dash' do
              expect(module_ancestor).to allow_value("#{first_letter}-").for(:reference_name)
            end

            it 'should allow digit' do
              expect(module_ancestor).to allow_value("#{first_letter}1").for(:reference_name)
            end

            it 'should allow uppercase letter' do
              expect(module_ancestor).to allow_value("#{first_letter}A").for(:reference_name)
            end

            it 'should allow underscore' do
              expect(module_ancestor).to allow_value("#{first_letter}_").for(:reference_name)
            end

            it 'should allow lowercase letter' do
              expect(module_ancestor).to allow_value("#{first_letter}a").for(:reference_name)
            end
          end
        end

        context 'with slashes' do
          let(:section) do
            "-_0a"
          end

          context 'leading' do
            it "should not allow '/'" do
              expect(module_ancestor).not_to allow_value("/#{section}").for(:reference_name)
            end

            it "should not allow '\\'" do
              expect(module_ancestor).not_to allow_value("\\#{section}").for(:reference_name)
            end
          end

          context 'infix' do
            it "should allow '/'" do
              expect(module_ancestor).to allow_value("#{section}/#{section}").for(:reference_name)
            end

            it "should not allow '\\'" do
              expect(module_ancestor).not_to allow_value("#{section}\\#{section}").for(:reference_name)
            end
          end

          context 'trailing' do
            it "should not allow '/'" do
              expect(module_ancestor).not_to allow_value("#{section}/").for(:reference_name)
            end

            it "should not allow '\\'" do
              expect(module_ancestor).not_to allow_value("#{section}\\").for(:reference_name)
            end
          end
        end

        context 'real-world examples' do
          it { should allow_value('admin/2wire/xslt_password_reset').for(:reference_name) }
          it { should allow_value('dos/http/3com_superstack_switch').for(:reference_name) }
          it { should allow_value('windows/brightstor/tape_engine_8A').for(:reference_name) }
          it { should allow_value('windows/fileformat/a-pdf_wav_to_mp3').for(:reference_name) }
          it { should allow_value('windows/ftp/32bitftp_list_reply').for(:reference_name) }
          it { should allow_value('windows/ftp/3cdaemon_ftp_user').for(:reference_name) }
        end
      end

      context 'validates uniqueness scoped to module_type' do
        subject(:new_ancestor) do
          FactoryGirl.build(
              :metasploit_cache_module_ancestor,
              :module_type => new_module_type,
              :reference_name => new_reference_name
          )
        end

        let(:original_module_type) do
          # don't use payload so sequence can be used to generate reference_name
          FactoryGirl.generate :metasploit_cache_non_payload_module_type
        end

        let(:original_reference_name) do
          FactoryGirl.generate :metasploit_cache_module_ancestor_non_payload_reference_name
        end

        let!(:original_ancestor) do
          FactoryGirl.create(
              :metasploit_cache_module_ancestor,
              :module_type => original_module_type,
              :reference_name => original_reference_name
          )
        end

        context 'with same module_type' do
          let(:new_module_type) do
            original_module_type
          end

          context 'with same reference_name' do
            let(:new_reference_name) do
              original_reference_name
            end

            context 'with batched' do
              include_context 'Metasploit::Cache::Batch.batch'

              it 'should not add error on #reference_name' do
                new_ancestor.valid?

                expect(new_ancestor.errors[:reference_name]).not_to include(taken_error)
              end

              it 'should raise ActiveRecord::RecordNotUnique when saved' do
                expect {
                  new_ancestor.save
                }.to raise_error(ActiveRecord::RecordNotUnique)
              end
            end

            context 'without batched' do
              it 'should add error on #reference_name' do
                new_ancestor.valid?

                expect(new_ancestor.errors[:reference_name]).to include(taken_error)
              end
            end
          end
        end

        context 'without same module_type' do
          let(:new_module_type) do
            # don't use payload so sequence can be used to generate reference_name
            FactoryGirl.generate :metasploit_cache_non_payload_module_type
          end

          context 'with same reference_name' do
            let(:new_reference_name) do
              original_reference_name
            end

            context 'with batched' do
              include_context 'Metasploit::Cache::Batch.batch'

              it 'should not record error on reference_name' do
                new_ancestor.valid?

                expect(new_ancestor.errors[:reference_name]).to be_empty
              end
            end

            context 'without batched' do
              it 'should not record error on reference_name' do
                new_ancestor.valid?

                expect(new_ancestor.errors[:reference_name]).to be_empty
              end
            end
          end
        end
      end
    end
  end

  context '#contents' do
    subject(:contents) do
      module_ancestor.contents
    end

    before(:each) do
      module_ancestor.real_path = real_path
    end

    context 'with #real_path' do
      let(:real_path) do
        module_ancestor.derived_real_path
      end

      context 'with file' do
        let(:file_contents) do
          "# Contents"
        end

        before(:each) do
          File.open(real_path, 'wb') do |f|
            f.write(file_contents)
          end
        end

        it 'should be contents of file' do
          expect(contents).to eq(file_contents)
        end
      end

      context 'without file' do
        before(:each) do
          File.delete(real_path)
        end

        it { should be_nil }
      end
    end

    context 'without #real_path' do
      let(:real_path) do
        nil
      end

      it { should be_nil }
    end
  end

  context '#derived_module_type' do
    subject(:derived_module_type) do
      module_ancestor.derived_module_type
    end

    before(:each) do
      module_ancestor.real_path = real_path
    end

    context 'with #real_path' do
      let(:real_path) do
        module_ancestor.derived_real_path
      end

      before(:each) do
        module_ancestor.parent_path = module_path
      end

      context 'with Metasploit::Cache::Module::Path' do
        let(:module_path) do
          module_ancestor.parent_path
        end

        before(:each) do
          module_path.real_path = module_path_real_path
        end

        context 'with Metasploit::Cache::Module::Path#real_path' do
          let(:module_path_real_path) do
            module_path.real_path
          end

          it { should_not be_nil }
        end

        context 'without Metasploit::Cache::Module::Path#real_path' do
          let(:module_path_real_path) do
            nil
          end

          it { should be_nil }
        end
      end

      context 'without Metasploit::Cache::Module::Path' do
        let(:module_path) do
          nil
        end

        it { should be_nil }
      end
    end

    context 'without #real_path' do
      let(:real_path) do
        nil
      end

      it { should be_nil }
    end
  end

  context '#derived_real_path' do
    subject(:derived_real_path) do
      module_ancestor.derived_real_path
    end

    let(:module_ancestor) do
      FactoryGirl.build(
          :metasploit_cache_module_ancestor,
          :module_type => module_type,
          :parent_path => parent_path,
          :reference_name => reference_name
      )
    end

    let(:module_type) do
      nil
    end

    let(:reference_name) do
      nil
    end

    context 'with parent_path' do
      let(:parent_path) do
        FactoryGirl.build(
            :metasploit_cache_module_path,
            :real_path => parent_path_real_path
        )
      end

      context 'with parent_path.real_path' do
        let(:parent_path_real_path) do
          FactoryGirl.generate :metasploit_cache_module_path_real_path
        end

        context 'with module_type' do
          let(:module_type) do
            FactoryGirl.generate :metasploit_cache_module_type
          end

          context 'with reference_name' do
            let(:reference_name) do
              FactoryGirl.generate :metasploit_cache_module_ancestor_non_payload_reference_name
            end

            it 'should be full path including parent_path.real_path, type_directory, and reference_path' do
              expect(derived_real_path).to eq(
                                               File.join(
                                                   parent_path_real_path,
                                                   module_ancestor.module_type_directory,
                                                   module_ancestor.reference_path
                                               )
                                           )
            end
          end

          context 'without reference_name' do
            let(:reference_name) do
              nil
            end

            it { should be_nil }
          end
        end

        context 'without module_type' do
          let(:module_type) do
            nil
          end

          it { should be_nil }
        end
      end

      context 'without parent_path.real_path' do
        let(:parent_path_real_path) do
          nil
        end

        it { should be_nil }
      end
    end

    context 'without parent_path' do
      let(:parent_path) do
        nil
      end

      it { should be_nil }
    end
  end

  context '#derived_real_path_modified_at' do
    subject(:derived_real_path_modified_at) do
      module_ancestor.derived_real_path_modified_at
    end

    let(:module_ancestor) do
      FactoryGirl.build(:metasploit_cache_module_ancestor)
    end

    context 'with real_path' do
      before(:each) do
        module_ancestor.real_path = real_path
      end

      context 'that exists' do
        let(:real_path) do
          # derived real path will have been created by factory's after(:build)
          module_ancestor.derived_real_path
        end

        it 'should be modification time of file' do
          expect(derived_real_path_modified_at).to eq(File.mtime(real_path))
        end

        it 'should be in UTC' do
          expect(derived_real_path_modified_at.zone).to eq('UTC')
        end
      end

      context 'that does not exist' do
        let(:real_path) do
          'non/existent/path'
        end

        it { should be_nil }
      end
    end

    context 'without real_path' do
      before(:each) do
        module_ancestor.real_path = nil
      end

      it 'should have nil for real_path' do
        expect(module_ancestor.real_path).to be_nil
      end

      it { should be_nil }
    end
  end

  context '#derived_real_path_sha1_hex_digest' do
    subject(:derived_real_path_sha1_hex_digest) do
      module_ancestor.derived_real_path_sha1_hex_digest
    end

    let(:module_ancestor) do
      FactoryGirl.build(:metasploit_cache_module_ancestor)
    end

    context 'with real_path' do
      before(:each) do
        module_ancestor.real_path = module_ancestor.derived_real_path
      end

      context 'that exists' do
        it 'should read the using Digest::SHA1.file' do
          expect(Digest::SHA1).to receive(:file).with(module_ancestor.real_path).and_call_original

          derived_real_path_sha1_hex_digest
        end

        context 'with content' do
          let(:content_sha1_hex_digest) do
            Digest::SHA1.hexdigest(content)
          end

          before(:each) do
            File.open(module_ancestor.real_path, 'wb') do |f|
              f.write(content)
            end
          end

          context 'that is empty' do
            let(:content) do
              ''
            end

            it 'should have empty file at real_path' do
              expect(File.size(module_ancestor.real_path)).to be_zero
            end

            it 'should have SHA1 hex digest for empty string' do
              expect(derived_real_path_sha1_hex_digest).to eq(content_sha1_hex_digest)
            end
          end

          context 'that is not empty' do
            let(:content) do
              "# Non-empty content"
            end

            it 'should have SHA1 hex digest for content' do
              expect(derived_real_path_sha1_hex_digest).to eq(content_sha1_hex_digest)
            end
          end
        end
      end

      context 'that does not exist' do
        before(:each) do
          File.delete(module_ancestor.real_path)
        end

        it { should be_nil }
      end
    end

    context 'without real_path' do
      before(:each) do
        module_ancestor.real_path = nil
      end

      it 'should have nil for real_path' do
        expect(module_ancestor.real_path).to be_nil
      end

      it { should be_nil }
    end
  end

  context '#derived_reference_name' do
    subject(:derived_reference_name) do
      module_ancestor.derived_reference_name
    end

    before(:each) do
      allow(module_ancestor).to receive(:relative_file_names).and_return(relative_file_names)
    end

    context 'with empty #relative_file_names' do
      let(:relative_file_names) do
        Enumerator.new { }
      end

      it { should be_nil }
    end

    context 'without empty #relative_file_names' do
      context 'with one element' do
        context 'with EXTENSION' do
          let(:relative_file_names) do
            ["a#{described_class::EXTENSION}"].each
          end

          it { is_expected.to be_nil }
        end

        context 'without EXTENSION' do
          let(:relative_file_names) do
            ['a'].each
          end

          it { is_expected.to be_nil }
        end
      end

      context 'with more than one element' do
        context 'with EXTENSION' do
          let(:relative_file_names) do
            ['a', 'b', "c#{described_class::EXTENSION}"].each
          end

          it 'should not include first file name' do
            expect(derived_reference_name.split(described_class::REFERENCE_NAME_SEPARATOR)).not_to include('a')
          end

          it 'should match REFERENCE_NAME_REGEXP' do
            expect(derived_reference_name).to match(described_class::REFERENCE_NAME_REGEXP)
          end

          it 'should not include EXTENSION' do
            expect(derived_reference_name).not_to end_with(described_class::EXTENSION)
          end

          it 'should be all file names except the first joined with the REFERENCE_NAME_SEPARATOR with EXTENSION' do
            expect(derived_reference_name).to eq("b#{described_class::REFERENCE_NAME_SEPARATOR}c")
          end
        end

        context 'without EXTENSION' do
          let(:relative_file_names) do
            ['a', 'b', 'c'].each
          end

          it { should be_nil }
        end
      end
    end
  end

  context '#loading_context?' do
    subject(:loading_context?) do
      module_ancestor.send(:loading_context?)
    end

    context 'with valid?' do
      it 'should be false' do
        expect(module_ancestor).to receive(:run_validations!) do
          expect(loading_context?).to eq(false)
        end

        module_ancestor.valid?
      end
    end

    context 'with valid?(:loading)' do
      it 'should be true' do
        expect(module_ancestor).to receive(:run_validations!) do
          expect(loading_context?).to eq(true)
        end

        module_ancestor.valid?(:loading)
      end
    end
  end

  context '#payload?' do
    subject(:module_ancestor) do
      described_class.new(:module_type => module_type)
    end

    context "with 'payload' module_type" do
      let(:module_type) do
        'payload'
      end

      it { should be_payload }
    end

    context "without 'payload' module_type" do
      let(:module_type) do
        FactoryGirl.generate :metasploit_cache_non_payload_module_type
      end

      it { should_not be_payload }
    end
  end

  context '#payload_type_directory' do
    subject(:payload_type_directory) do
      module_ancestor.payload_type_directory
    end

    let(:module_ancestor) do
      FactoryGirl.build(
          :metasploit_cache_module_ancestor,
          module_type: module_type
      )
    end

    context 'with payload' do
      let(:module_type) do
        'payload'
      end

      before(:each) do
        module_ancestor.reference_name = reference_name
      end

      context 'with #reference_name' do
        let(:expected_payload_type_directory) do
          payload_type_directories.sample
        end

        let(:payload_type_directories) do
          [
              'singles',
              'stages',
              'stagers'
          ]
        end

        let(:reference_name) do
          "#{expected_payload_type_directory}/reference/name/tail"
        end

        it 'is name before REFERENCE_NAME_SEPARATOR' do
          expect(payload_type_directory).to eq(expected_payload_type_directory)
        end
      end

      context 'without #reference_name' do
        let(:reference_name) do
          nil
        end

        it { should be_nil }
      end
    end

    context 'without payload' do
      let(:module_type) do
        FactoryGirl.generate :metasploit_cache_non_payload_module_type
      end

      it { should be_nil }
    end
  end

  context '#relative_file_names' do
    subject(:relative_file_names) do
      module_ancestor.relative_file_names
    end

    before(:each) do
      allow(module_ancestor).to receive(:relative_pathname).and_return(relative_pathname)
    end

    context 'with #relative_pathnames' do
      let(:file_names) do
        [
            'a',
            'b',
            'c'
        ]
      end

      let(:relative_pathname) do
        Pathname.new(file_names.join('/'))
      end

      it { should be_an Enumerator }

      it 'should include all file names, in order' do
        expect(relative_file_names.to_a).to eq(file_names)
      end
    end

    context 'without #relative_pathnames' do
      let(:relative_pathname) do
        nil
      end

      it { should be_an Enumerator }

      it 'is empty' do
        expect(relative_file_names.to_a).to be_empty
      end
    end
  end

  context '#relative_pathname' do
    subject(:relative_pathname) do
      module_ancestor.relative_pathname
    end

    before(:each) do
      allow(module_ancestor).to receive(:real_pathname).and_return(real_pathname)
    end

    context 'with #real_pathname' do
      let(:real_pathname) do
        Pathname.new('a/b/c')
      end

      before(:each) do
        module_ancestor.parent_path = parent_path
      end

      context 'with #parent_path' do
        let(:parent_path) do
          module_ancestor.parent_path
        end

        before(:each) do
          allow(parent_path).to receive(:real_pathname).and_return(parent_path_real_pathname)
        end

        context 'with Metasploit::Cache::Module::Path#real_pathname' do
          let(:parent_path_real_pathname) do
            Pathname.new('a')
          end

          it { should be_a Pathname }
          it { should be_relative }

          it 'should be relative to parent_path.real_pathname' do
            expect(relative_pathname).to eq(Pathname.new('b/c'))
          end
        end

        context 'without Metasploit::Cache::Module::Path#real_pathname' do
          let(:parent_path_real_pathname) do
            nil
          end

          it { should be_nil }
        end
      end

      context 'without #parent_path' do
        let(:parent_path) do
          nil
        end

        it { should be_nil }
      end
    end

    context 'without #real_pathname' do
      let(:real_pathname) do
        nil
      end

      it { should be_nil }
    end
  end

  context '#reference_path' do
    subject(:reference_path) do
      module_ancestor.reference_path
    end

    let(:module_ancestor) do
      described_class.new(
          :reference_name => reference_name
      )
    end

    context 'with reference_name' do
      let(:reference_name) do
        FactoryGirl.generate :metasploit_cache_module_ancestor_non_payload_reference_name
      end

      it 'should be reference_name + EXTENSION' do
        expect(reference_path).to eq("#{reference_name}#{Metasploit::Cache::Module::Ancestor::EXTENSION}")
      end
    end

    context 'without reference_name' do
      let(:reference_name) do
        nil
      end

      it { should be_nil }
    end
  end

  context '#module_type_directory' do
    subject(:module_type_directory) do
      module_ancestor.module_type_directory
    end

    let(:module_ancestor) do
      described_class.new(
          :module_type => module_type
      )
    end

    context 'with module_type' do
      context 'in known types' do
        let(:module_type) do
          FactoryGirl.generate :metasploit_cache_module_type
        end

        it 'should use Metasploit::Cache::Module::Ancestor::DIRECTORY_BY_MODULE_TYPE' do
          expect(module_type_directory).to eq(Metasploit::Cache::Module::Ancestor::DIRECTORY_BY_MODULE_TYPE[module_type])
        end
      end

      context 'in unknown types' do
        let(:module_type) do
          'not_a_type'
        end

        it { should be_nil }
      end
    end

    context 'without module_type' do
      let(:module_type) do
        nil
      end

      it { should be_nil }
    end
  end
end