# Acts as a stand-in for metasploit-framework's `Msf::Module.is_usable`'s behavior.
#
# @example A dummy Metasploit Classs
#   class Metasploit4
#     extend Metasploit::Cache::Direct::Class::Usability
#   end
module Metasploit::Cache::Direct::Class::Usability
  # This method allows Metasploit Classes to tell the framework if they are usable on the system that they are being
  # loaded on in a generic fashion. By default, all modules are indicated as being usable.  An example of where this is
  # useful is if the module depends on something external to Ruby, such as a binary.
  #
  # @return [true] Metasploit Class is usable and should be loaded.
  # @return [false] Metasploit Class is not usable and should not be loaded.
  def is_usable
    true
  end
end