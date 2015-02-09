# Open Sourced Vulnerability Database authority-specific code.
module Metasploit::Cache::Authority::Osvdb
  # Returns URL to {Metasploit::Cache::Reference#designation OSVDB ID's} page.
  #
  # @param designation [String] N+ OSVDB ID.
  # @return [String] URL
  def self.designation_url(designation)
    "http://www.osvdb.org/#{designation}/"
  end
end
