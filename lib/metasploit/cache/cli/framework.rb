# A fake `Msf::Simple::Framework` with just enough of the API to support instantiating Metasploit Modules
class Metasploit::Cache::CLI::Framework
  # Required by some auxiliary modules as framework is used as a fallback if a Metasploit Module instance's datastore
  # does not have a key.
  #
  # @return [Hash]
  def datastore
    {}.freeze
  end
end