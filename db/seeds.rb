Metasploit::Cache::Architecture::Seed.seed

authority_attributes = [
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
authority_attributes.each do |attributes|
  abbreviation = attributes.fetch(:abbreviation)

  # abbreviation is the only unique and :null => false column, so use it to look for updates.  Authority may be updated
  # if obsolete, summary, or url are currently nil, but attributes has non-nil value as could occur if authority is made
  # from module metadata before a seed exists.
  authority = Metasploit::Cache::Authority.where(:abbreviation => abbreviation).first_or_initialize

  # can use ||= with boolean column because whoever asserts the authority is obsolete wins
  authority.obsolete ||= attributes.fetch(:obsolete)

  authority.summary ||= attributes.fetch(:summary)
  authority.url ||= attributes.fetch(:url)

  authority.save!
end

Metasploit::Cache::Platform.each_seed_attributes do |attributes|
  parent = attributes.fetch(:parent)
  relative_name = attributes.fetch(:relative_name)
  parent_id = nil

  if parent
    parent_id = parent.id
  end

  child = Metasploit::Cache::Platform.where(parent_id: parent_id, relative_name: relative_name).first

  unless child
    child = Metasploit::Cache::Platform.new
    child.parent = parent
    child.relative_name = relative_name
    child.save!
  end

  # yieldreturn
  child
end

Metasploit::Cache::Module::Rank::NUMBER_BY_NAME.each do |name, number|
  Metasploit::Cache::Module::Rank.where(:name => name, :number => number).first_or_create!
end