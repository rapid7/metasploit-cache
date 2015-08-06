# Common Weakness Enumeration authority-specific code.
module Metasploit::Cache::Authority::Cwe
  # Returns URL to {Metasploit::Cache::Reference#designation Weakness ID's} page.
  #
  # @param designation [String] N+ Weakness ID
  # @return [String] URL
  def self.designation_url(designation)
    "https://cwe.mitre.org/data/definitions/#{designation}.html"
  end
end
