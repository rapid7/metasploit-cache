# Acts as a stand-in for metasploit-framework's `Msf::Module.framework` attribute.
#
# @example A dummy Metasploit Class
#   class Metasploit4
#     extend Metasploit::Cache::Direct::Class::Framework
#   end
#
#  Metasploit4.framework = metasploit_framework
module Metasploit::Cache::Direct::Class::Framework
  #
  # Attributes
  #

  # Framework that `#initialize` can access Metasploit Framework world state.
  #
  # @return [#events]
  attr_accessor :framework
end