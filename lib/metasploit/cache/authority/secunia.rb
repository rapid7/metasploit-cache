# Secunia authority-specific code.
module Metasploit::Cache::Authority::Secunia
  # Returns URL to {Metasploit::Cache::Reference#designation Secunia Advisory ID's} page on Secunia.
  #
  # @param designation [String] NNNNN Secunia Advisory ID.
  # @return [String] URL
  def self.designation_url(designation)
    "https://secunia.com/advisories/#{designation}/"
  end
end
