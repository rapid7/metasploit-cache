# Fakes `Msf::Framework::EventDispatcher` API used when loading Metasploit Modules.
class Events
  # Fakes adding an exploit event subscriber
  #
  # @param _metasploit_module_instance [Object] ignored
  # @return [void]
  def add_exploit_subscriber(_metasploit_module_instance)
  end
end


