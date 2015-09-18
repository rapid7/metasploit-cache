# A fake `Msf::Simple::Framework` with just enough of the API to support instantiating Metasploit Modules
class Metasploit::Cache::CLI::Framework
  extend ActiveSupport::Autoload

  autoload :Events

  # Required by some auxiliary modules as framework is used as a fallback if a Metasploit Module instance's datastore
  # does not have a key.
  #
  # @return [Hash]
  def datastore
    {}.freeze
  end

  # Event source.
  #
  # @return [nil]
  def events
    @events ||= Events.new.freeze
  end
end