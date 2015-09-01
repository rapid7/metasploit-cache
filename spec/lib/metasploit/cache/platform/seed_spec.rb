RSpec.describe Metasploit::Cache::Platform::Seed do
  context 'CONSTANTS' do
    context 'RELATIVE_NAME_TREE' do
      subject(:relative_name_tree) do
        described_class::RELATIVE_NAME_TREE
      end

      it { should include('AIX') }
      it { should include('Android') }
      it { should include('BSD') }
      it { should include('BSDi') }
      it { should include('Cisco') }
      it { should include('Firefox') }
      it { should include('FreeBSD') }
      it { should include('HPUX') }
      it { should include('Irix') }
      it { should include('Java') }
      it { should include('JavaScript') }
      it { should include('Linux') }
      it { should include('NetBSD') }
      it { should include('Netware') }
      it { should include('NodeJS') }
      it { should include('OpenBSD') }
      it { should include('OSX') }
      it { should include('PHP') }
      it { should include('Python') }
      it { should include('Ruby') }

      context "['Solaris']" do
        subject(:solaris) do
          relative_name_tree['Solaris']
        end

        it { should include('4') }
        it { should include('5') }
        it { should include('6') }
        it { should include('7') }
        it { should include('8') }
        it { should include('9') }
        it { should include('10') }
      end

      context "['Windows']" do
        subject(:windows) do
          relative_name_tree['Windows']
        end

        it { should include('95') }

        context "['98']" do
          subject(:ninety_eight) do
            windows['98']
          end

          it { should include('FE') }
          it { should include('SE') }
        end

        it { should include('ME') }

        context "['NT']" do
          subject(:nt) do
            windows['NT']
          end

          it { should include('SP0') }
          it { should include('SP1') }
          it { should include('SP2') }
          it { should include('SP3') }
          it { should include('SP4') }
          it { should include('SP5') }
          it { should include('SP6') }
          it { should include('SP6a') }
        end

        context "['2000']" do
          subject(:two_thousand) do
            windows['2000']
          end

          it { should include('SP0') }
          it { should include('SP1') }
          it { should include('SP2') }
          it { should include('SP3') }
          it { should include('SP4') }
        end

        context "['XP']" do
          subject(:xp) do
            windows['XP']
          end

          it { should include('SP0') }
          it { should include('SP1') }
          it { should include('SP2') }
          it { should include('SP3') }
        end

        context "['2003']" do
          subject(:two_thousand_three) do
            windows['2003']
          end

          it { should include('SP0') }
          it { should include('SP1') }
        end

        context "['Vista']" do
          subject(:vista) do
            windows['Vista']
          end

          it { should include('SP0') }
          it { should include('SP1') }
        end

        it { should include('7') }
        it { should include('8') }
        it { should include('10') }
      end

      it { should include('Unix') }
    end
  end
end