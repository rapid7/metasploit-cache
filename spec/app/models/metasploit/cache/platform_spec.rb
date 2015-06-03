RSpec.describe Metasploit::Cache::Platform do
  subject(:platform) do
    FactoryGirl.generate :metasploit_cache_platform
  end

  context 'associations' do
    it { should have_many(:module_instances).class_name('Metasploit::Cache::Module::Instance').through(:module_platforms) }
    it { should have_many(:module_platforms).class_name('Metasploit::Cache::Module::Platform').dependent(:destroy) }
    it { is_expected.to have_many(:platformable_platforms).class_name('Metasploit::Cache::Platformable::Platform').dependent(:destroy).inverse_of(:platform) }
    it { should have_many(:target_platforms).class_name('Metasploit::Cache::Module::Target::Platform').dependent(:destroy) }
  end

  context 'database' do
    context 'columns' do
      context 'nested set' do
        it { should have_db_column(:parent_id).of_type(:integer).with_options(null: true) }
        it { should have_db_column(:right).of_type(:integer).with_options(null: false) }
        it { should have_db_column(:left).of_type(:integer).with_options(null: false) }
      end

      context 'platform' do
        it { should have_db_column(:fully_qualified_name).of_type(:text).with_options(null: false) }
        it { should have_db_column(:relative_name).of_type(:text).with_options(null: false) }
      end
    end

    context 'indices' do
      it { should have_db_index(:fully_qualified_name).unique(true) }
      it { should have_db_index([:parent_id, :relative_name]).unique(true) }
    end
  end

  context 'derivations' do
    include_context 'ActiveRecord attribute_type'

    subject(:platform) do
      # have to tap to bypass mass-assignment security
      base_class.new.tap { |platform|
        platform.parent = windows
        # need to use a real name or derivation won't be valid because it won't be in fully_qualified_names.
        platform.relative_name = 'XP'
      }
    end

    let(:base_class) {
      Metasploit::Cache::Platform
    }

    let(:windows) do
      base_class.all.find { |platform|
        # need to use a real name or derivation won't be valid because it won't be in fully_qualified_names.
        platform.fully_qualified_name == 'Windows'
      }
    end

    it_should_behave_like 'derives', :fully_qualified_name, :validates => true
  end

  context 'mass assignment security' do
    it { should allow_mass_assignment_of(:relative_name) }
  end

  context 'search' do
    let(:base_class) {
      Metasploit::Cache::Platform
    }
    
    context 'attributes' do
      it_should_behave_like 'search_attribute',
                            :fully_qualified_name,
                            type: {
                                set: :string
                            }
    end
  end
  
  context 'sequences' do
    context 'metasploit_cache_platform' do
      subject(:metasploit_cache_platform) {
        FactoryGirl.generate :metasploit_cache_platform
      }

      context 'with seeded' do
        it 'does not create a new Metasploit::Cache::Platform' do
          expect {
            metasploit_cache_platform
          }.not_to change(Metasploit::Cache::Platform, :count)
        end

        it { is_expected.to be_a(Metasploit::Cache::Platform) }
        it { is_expected.to be_persisted }
      end

      context 'without seeded' do
        before(:each) do
          Metasploit::Cache::Platform.delete_all
        end

        it 'raises ArgumentError with the fully_qualified_name of the unseeded rank' do
          expect {
            metasploit_cache_platform
          }.to raise_error(ArgumentError) do |error|
            expect(error.to_s).to match(/Metasploit::Cache::Platform with fully_qualified_name \(.+\) has not been seeded/)
          end
        end
      end
    end
  end
  
  context 'validations' do
    it { should validate_presence_of(:relative_name) }
  end

  # @note Not tested in 'Metasploit::Cache::Platform' shared example because it is a module method and not a class
  #   method because seeding should always refer back to {Metasploit::Cache::Platform} and not the classes in which
  #   it is included.
  context '.fully_qualified_names' do
    subject(:fully_qualified_name_set) do
      described_class.fully_qualified_name_set
    end

    it { should include 'AIX' }
    it { should include 'Android' }
    it { should include 'BSD' }
    it { should include 'BSDi' }
    it { should include 'Cisco' }
    it { should include 'Firefox' }
    it { should include 'FreeBSD' }
    it { should include 'HPUX' }
    it { should include 'IRIX' }
    it { should include 'Java' }
    it { should include 'Javascript' }
    it { should include 'NetBSD' }
    it { should include 'Netware' }
    it { should include 'NodeJS' }
    it { should include 'OpenBSD' }
    it { should include 'OSX' }
    it { should include 'PHP' }
    it { should include 'Python' }
    it { should include 'Ruby' }

    it { should include 'Solaris'}
    it { should include 'Solaris 4' }
    it { should include 'Solaris 5' }
    it { should include 'Solaris 6' }
    it { should include 'Solaris 7' }
    it { should include 'Solaris 8' }
    it { should include 'Solaris 9' }
    it { should include 'Solaris 10' }

    it { should include 'Windows' }

    it { should include 'Windows 95' }

    it { should include 'Windows 98' }
    it { should include 'Windows 98 FE' }
    it { should include 'Windows 98 SE' }

    it { should include 'Windows ME' }

    it { should include 'Windows NT' }
    it { should include 'Windows NT SP0' }
    it { should include 'Windows NT SP1' }
    it { should include 'Windows NT SP2' }
    it { should include 'Windows NT SP3' }
    it { should include 'Windows NT SP4' }
    it { should include 'Windows NT SP5' }
    it { should include 'Windows NT SP6' }
    it { should include 'Windows NT SP6a' }

    it { should include 'Windows 2000' }
    it { should include 'Windows 2000 SP0' }
    it { should include 'Windows 2000 SP1' }
    it { should include 'Windows 2000 SP2' }
    it { should include 'Windows 2000 SP3' }
    it { should include 'Windows 2000 SP4' }

    it { should include 'Windows XP' }
    it { should include 'Windows XP SP0' }
    it { should include 'Windows XP SP1' }
    it { should include 'Windows XP SP2' }
    it { should include 'Windows XP SP3' }

    it { should include 'Windows 2003' }
    it { should include 'Windows 2003 SP0' }
    it { should include 'Windows 2003 SP1' }

    it { should include 'Windows Vista' }
    it { should include 'Windows Vista SP0' }
    it { should include 'Windows Vista SP1' }

    it { should include 'Windows 7' }

    it { should include 'UNIX' }
  end

  context '#derived_fully_qualified_name' do
    subject(:derived_fully_qualified_name) do
      platform.derived_fully_qualified_name
    end

    context 'with #relative_name' do
      context 'with #parent' do
        let(:platform) do
          described_class.all.select { |platform|
            platform.parent.present?
          }.sample
        end

        it "should be '<parent.fully_qualified_name> <relative_name>'" do
          expect(derived_fully_qualified_name).to eq("#{platform.parent.fully_qualified_name} #{platform.relative_name}")
        end
      end

      context 'without #parent' do
        let(:platform) do
          described_class.all.reject { |platform|
            platform.parent.present?
          }.sample
        end

        it 'should be #relative_name' do
          expect(derived_fully_qualified_name).to eq(platform.relative_name)
        end
      end
    end

    context 'without #relative_name' do
      let(:platform) do
        described_class.new
      end

      it { should be_nil }
    end
  end
end