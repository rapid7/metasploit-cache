# Acts as a stand-in for metasploit-framework's `Msf::Module`.
#
# @example a dummy Metasploit Class
#   class Metasploit4 < Metasploit::Cache::Direct::Class::Superclass
#   end
class Metasploit::Cache::Direct::Class::Superclass
  extend Metasploit::Cache::Direct::Class::Ranking
  extend Metasploit::Cache::Direct::Class::Usability
end