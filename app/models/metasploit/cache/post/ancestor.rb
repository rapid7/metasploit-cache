# Metadata from loading post Metasploit Modules.
class Metasploit::Cache::Post::Ancestor < Metasploit::Cache::Module::Ancestor
  Metasploit::Cache::Module::Ancestor.restrict(self, to: 'post')

  Metasploit::Concern.run(self)
end