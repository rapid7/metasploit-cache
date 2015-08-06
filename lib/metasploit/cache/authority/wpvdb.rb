# WPScan Vulnerability Database authority-specific code.
module Metasploit::Cache::Authority::Wpvdb
  # Returns URL to {Metasploit::Cache::Reference#designation Vulnerability ID's} page.
  #
  # @param designation [String] N+ Vulnerability ID
  # @return [String] URL
  def self.designation_url(designation)
    "https://wpvulndb.com/vulnerabilities/#{designation}"
  end
end
