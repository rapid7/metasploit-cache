class Metasploit::Cache::Payload::Stager::Ancestor < Metasploit::Cache::Payload::Ancestor
  Metasploit::Cache::Payload::Ancestor.restrict(self, to: 'stager')

  Metasploit::Concern.run(self)
end