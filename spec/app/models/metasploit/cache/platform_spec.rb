require 'spec_helper'

RSpec.describe Metasploit::Cache::Platform do
  it_should_behave_like 'Metasploit::Cache::Platform',
                        namespace_name: 'Metasploit::Cache' do
    include_context 'ActiveRecord attribute_type'
  end

  context 'associations' do
    it { should have_many(:module_instances).class_name('Metasploit::Cache::Module::Instance').through(:module_platforms) }
    it { should have_many(:module_platforms).class_name('Metasploit::Cache::Module::Platform').dependent(:destroy) }
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
end