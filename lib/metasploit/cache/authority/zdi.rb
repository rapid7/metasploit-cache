# Zero Day Initiative authority-specific code.
module Metasploit::Cache::Authority::Zdi
  # Returns URL to {Metasploit::Cache::Reference#designation the ZDI ID's} page on ZDI.
  #
  # @param designation [String] YY-NNNN ZDI ID.
  # @return [String] URL
  def self.designation_url(designation)
    "http://www.zerodayinitiative.com/advisories/ZDI-#{designation}"
  end
end