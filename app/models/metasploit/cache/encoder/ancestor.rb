# Metadata from loading encoder Metasploit Modules.
class Metasploit::Cache::Encoder::Ancestor < Metasploit::Cache::Module::Ancestor
  Metasploit::Cache::Module::Ancestor.restrict(self, to: 'encoder')

  Metasploit::Concern.run(self)
end