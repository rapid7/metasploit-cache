# Namespace for `Module`s that help with writing specs for {Metasploit::Cache::Payload::Ancestor}.
module Metasploit::Cache::Payload::Ancestor::Spec
  #
  # CONSTANTS
  #

  # Factories for {Metasploit::Cache::Payload::Ancestor} subclasses.
  FACTORIES = [
      :metasploit_cache_payload_single_ancestor,
      :metasploit_cache_payload_stage_ancestor,
      :metasploit_cache_payload_stager_ancestor
  ]

  #
  # Module Methods
  #

  # Stream of elements of {FACTORIES}.
  #
  # @return [Enumerator<Symbol>]
  def self.random_factory
    Enumerator.new do |yielder|
      loop do
        yielder.yield FACTORIES.sample
      end
    end
  end
end