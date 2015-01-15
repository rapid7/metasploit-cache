module Metasploit::Cache::Architecture::Seed
  # Attributes for seeds.
  ATTRIBUTES = [
      {
          :abbreviation => 'armbe',
          :bits => 32,
          :endianness => 'big',
          :family => 'arm',
          :summary => 'Little-endian ARM'
      },
      {
          :abbreviation => 'armle',
          :bits => 32,
          :endianness => 'little',
          :family => 'arm',
          :summary => 'Big-endian ARM'
      },
      {
          :abbreviation => 'cbea',
          :bits => 32,
          :endianness => 'big',
          :family => 'cbea',
          :summary => '32-bit Cell Broadband Engine Architecture'
      },
      {
          :abbreviation => 'cbea64',
          :bits => 64,
          :endianness => 'big',
          :family => 'cbea',
          :summary => '64-bit Cell Broadband Engine Architecture'
      },
      {
          :abbreviation => 'cmd',
          :bits => nil,
          :endianness => nil,
          :family => nil,
          :summary => 'Command Injection'
      },
      {
          :abbreviation => 'dalvik',
          :bits => nil,
          :endianness => nil,
          :family => nil,
          :summary => 'Dalvik process virtual machine used in Google Android'
      },
      {
          abbreviation: 'firefox',
          bits: nil,
          endianness: nil,
          family: 'javascript',
          summary: "Firefox's privileged javascript API"
      },
      {
          :abbreviation => 'java',
          :bits => nil,
          :endianness => 'big',
          :family => nil,
          :summary => 'Java'
      },
      {
          :abbreviation => 'mipsbe',
          :bits => 32,
          :endianness => 'big',
          :family => 'mips',
          :summary => 'Big-endian MIPS'
      },
      {
          :abbreviation => 'mipsle',
          :bits => 32,
          :endianness => 'little',
          :family => 'mips',
          :summary => 'Little-endian MIPS'
      },
      {
          abbreviation: 'nodejs',
          bits: nil,
          endianness: nil,
          family: 'javascript',
          summary: 'NodeJS'
      },
      {
          :abbreviation => 'php',
          :bits => nil,
          :endianness => nil,
          :family => nil,
          :summary => 'PHP'
      },
      {
          :abbreviation => 'ppc',
          :bits => 32,
          :endianness => 'big',
          :family => 'ppc',
          :summary => '32-bit Peformance Optimization With Enhanced RISC - Performance Computing'
      },
      {
          :abbreviation => 'ppc64',
          :bits => 64,
          :endianness => 'big',
          :family => 'ppc',
          :summary => '64-bit Performance Optimization With Enhanced RISC - Performance Computing'
      },
      {
          :abbreviation => 'python',
          :bits => nil,
          :endianness => nil,
          :family => nil,
          :summary => 'Python'
      },
      {
          :abbreviation => 'ruby',
          :bits => nil,
          :endianness => nil,
          :family => nil,
          :summary => 'Ruby'
      },
      {
          :abbreviation => 'sparc',
          :bits => nil,
          :endianness => nil,
          :family => 'sparc',
          :summary => 'Scalable Processor ARChitecture'
      },
      {
          :abbreviation => 'tty',
          :bits => nil,
          :endianness => nil,
          :family => nil,
          :summary => '*nix terminal'
      },
      {
          :abbreviation => 'x86',
          :bits => 32,
          :endianness => 'little',
          :family => 'x86',
          :summary => '32-bit x86'
      },
      {
          :abbreviation => 'x86_64',
          :bits => 64,
          :endianness => 'little',
          :family => 'x86',
          :summary => '64-bit x86'
      }
  ]

  #
  # Module Methods
  #

  def self.seed
    ATTRIBUTES.each do |attributes|
      parent.where(attributes).first_or_create!
    end
  end
end