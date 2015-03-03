class Metasploit::Cache::Payload::Stage::Ancestor < Metasploit::Cache::Payload::Ancestor
  Metasploit::Cache::Payload::Ancestor.restrict(self, to: 'stage')

  Metasploit::Concern.run(self)
end