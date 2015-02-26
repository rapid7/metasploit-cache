# Metadata from loading nop Metasploit Modules.
class Metasploit::Cache::Nop::Ancestor < Metasploit::Cache::Module::Ancestor
  Metasploit::Cache::Module::Ancestor.restrict(self, to: 'nop')

  Metasploit::Concern.run(self)
end