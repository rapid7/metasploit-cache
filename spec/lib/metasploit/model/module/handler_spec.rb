require 'spec_helper'

RSpec.describe Metasploit::Model::Module::Handler do
  context 'CONSTANTS' do
    context 'GENERAL_TYPES' do
      subject(:general_types) do
        described_class::GENERAL_TYPES
      end

      it { should include 'bind' }
      it { should include 'find' }
      it { should include 'none' }
      it { should include 'reverse' }
      it { should include 'tunnel' }
    end

    context 'GENERAL_TYPE_BY_TYPE' do
      subject(:general_type_by_type) do
        described_class::GENERAL_TYPE_BY_TYPE
      end

      it "maps 'bind_tcp' to 'bind'" do
        expect(general_type_by_type['bind_tcp']).to eq('bind')
      end

      it "maps 'find_port' to 'find'" do
        expect(general_type_by_type['find_port']).to eq('find')
      end

      it "maps 'find_shell' to 'find'" do
        expect(general_type_by_type['find_shell']).to eq('find')
      end

      it "maps 'find_tag' to 'find'" do
        expect(general_type_by_type['find_tag']).to eq('find')
      end

      it "maps 'none' to 'none'" do
        expect(general_type_by_type['none']).to eq('none')
      end

      it "maps 'reverse_http' to 'tunnel'" do
        expect(general_type_by_type['reverse_http']).to eq('tunnel')
      end

      it "maps 'reverse_https' to 'tunnel'" do
        expect(general_type_by_type['reverse_https']).to eq('tunnel')
      end

      it "maps 'reverse_https_proxy' to 'tunnel'" do
        expect(general_type_by_type['reverse_https_proxy']).to eq('tunnel')
      end

      it "maps 'reverse_ipv6_http' to 'tunnel'" do
        expect(general_type_by_type['reverse_ipv6_http']).to eq('tunnel')
      end

      it "maps 'reverse_ipv6_https' to 'tunnel'" do
        expect(general_type_by_type['reverse_ipv6_https']).to eq('tunnel')
      end

      it "maps 'reverse_tcp' to 'reverse'" do
        expect(general_type_by_type['reverse_tcp']).to eq('reverse')
      end

      it "maps 'reverse_tcp_allports' to 'reverse'" do
        expect(general_type_by_type['reverse_tcp_allports']).to eq('reverse')
      end

      it "maps 'reverse_tcp_double' to 'reverse'" do
        expect(general_type_by_type['reverse_tcp_double']).to eq('reverse')
      end

      it "maps 'reverse_tcp_double_ssl' to 'reverse'" do
        expect(general_type_by_type['reverse_tcp_double_ssl']).to eq('reverse')
      end

      it "maps 'reverse_tcp_ssl' to 'reverse'" do
        expect(general_type_by_type['reverse_tcp_ssl']).to eq('reverse')
      end
    end

    context 'TYPES' do
      subject(:types) do
        described_class::TYPES
      end

      it { should include 'bind_tcp' }
      it { should include 'find_port' }
      it { should include 'find_shell' }
      it { should include 'find_tag' }
      it { should include 'none' }
      it { should include 'reverse_http' }
      it { should include 'reverse_https' }
      it { should include 'reverse_https_proxy' }
      it { should include 'reverse_ipv6_http' }
      it { should include 'reverse_ipv6_https' }
      it { should include 'reverse_tcp' }
      it { should include 'reverse_tcp_allports' }
      it { should include 'reverse_tcp_double' }
      it { should include 'reverse_tcp_double_ssl' }
      it { should include 'reverse_tcp_ssl' }
    end
  end
end