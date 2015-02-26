# Metadata from loading auxiliary modules.
class Metasploit::Cache::Auxiliary::Ancestor < Metasploit::Cache::Module::Ancestor
  Metasploit::Cache::Module::Ancestor.restrict(self, to: 'auxiliary')

  Metasploit::Concern.run(self)
end