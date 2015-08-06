# Exploit Database authority-specific code.
module Metasploit::Cache::Authority::Edb
  # Returns URL to {Metasploit::Cache::Reference#designation Exploit Database ID's} page.
  #
  # @param designation [String] N+ Exploit Database ID.
  # @return [String] URL
  def self.designation_url(designation)
    "https://www.exploit-db.com/exploits/#{designation}"
  end
end
