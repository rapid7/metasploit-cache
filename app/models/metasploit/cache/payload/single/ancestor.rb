class Metasploit::Cache::Payload::Single::Ancestor < Metasploit::Cache::Payload::Ancestor
  Metasploit::Cache::Payload::Ancestor.restrict(self, to: 'single')

  Metasploit::Concern.run(self)
end