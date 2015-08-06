# Seeds {Metasploit::Cache::Authority Metasploit::Cache::Authority}.
module Metasploit::Cache::Authority::Seed
  #
  # CONSTANTS
  #

  ATTRIBUTES = [
      {
          :abbreviation => 'BID',
          :obsolete => false,
          :summary => 'BuqTraq ID',
          :url => 'http://www.securityfocus.com/bid'
      },
      {
          :abbreviation => 'CVE',
          :obsolete => false,
          :summary => 'Common Vulnerabilities and Exposures',
          :url => 'http://cvedetails.com'
      },
      {
          abbreviation: 'CWE',
          obsolete: false,
          summary: 'Common Weakness Enumeration',
          url: 'https://cwe.mitre.org/data/index.html'
      },
      {
          abbreviation: 'EDB',
          obsolete: false,
          summary: 'Offensive Security Exploit Database Archive',
          url: 'https://www.exploit-db.com'
      },
      {
          :abbreviation => 'MIL',
          :obsolete => true,
          :summary => 'milw0rm',
          :url => 'https://en.wikipedia.org/wiki/Milw0rm'
      },
      {
          :abbreviation => 'MSB',
          :obsolete => false,
          :summary => 'Microsoft Security Bulletin',
          :url => 'http://www.microsoft.com/technet/security/bulletin'
      },
      {
          :abbreviation => 'OSVDB',
          :obsolete => false,
          :summary => 'Open Sourced Vulnerability Database',
          :url => 'http://osvdb.org'
      },
      {
          :abbreviation => 'PMASA',
          :obsolete => false,
          :summary => 'phpMyAdmin Security Announcement',
          :url => 'http://www.phpmyadmin.net/home_page/security/'
      },
      {
          :abbreviation => 'SECUNIA',
          :obsolete => false,
          :summary => 'Secunia',
          :url => 'https://secunia.com/advisories'
      },
      {
          :abbreviation => 'US-CERT-VU',
          :obsolete => false,
          :summary => 'United States Computer Emergency Readiness Team Vulnerability Notes Database',
          :url => 'http://www.kb.cert.org/vuls'
      },
      {
          :abbreviation => 'waraxe',
          :obsolete => false,
          :summary => 'Waraxe Advisories',
          :url => 'http://www.waraxe.us/content-cat-1.html'
      },
      {
          abbreviation: 'ZDI',
          obsolete: false,
          summary: 'Zero Day Initiative',
          url: 'http://www.zerodayinitiative.com/advisories'
      }
  ]

  #
  # Module Functions
  #

  # Seeds {Metasploit::Cache::Authority Metasploit::Cache::Authorities}.
  #
  # @return [void]
  def self.seed
    ATTRIBUTES.each do |attributes|
      abbreviation = attributes.fetch(:abbreviation)

      # abbreviation is the only unique and :null => false column, so use it to look for updates.  Authority may be updated
      # if obsolete, summary, or url are currently nil, but attributes has non-nil value as could occur if authority is made
      # from module metadata before a seed exists.
      authority = parent.where(abbreviation: abbreviation).first_or_initialize

      # can use ||= with boolean column because whoever asserts the authority is obsolete wins
      authority.obsolete ||= attributes.fetch(:obsolete)

      authority.summary ||= attributes.fetch(:summary)
      authority.url ||= attributes.fetch(:url)

      authority.save!
    end
  end
end