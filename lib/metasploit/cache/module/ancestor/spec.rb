# Namespace for `Module`s that help with writing specs for {Metasploit::Cache::Module::Ancestor}.
module Metasploit::Cache::Module::Ancestor::Spec
  #
  # CONSTANTS
  #

  # Factories for {Metasploit::Cache::Module::Ancestor} subclasses that are *NOT* {Metasploit::Cache::Payload::Ancestor}
  # subclasses
  NON_PAYLOAD_FACTORIES = [
      :metasploit_cache_auxiliary_ancestor,
      :metasploit_cache_encoder_ancestor,
      :metasploit_cache_exploit_ancestor,
      :metasploit_cache_nop_ancestor,
      :metasploit_cache_post_ancestor
  ]

  # Factories for {Metasploit::Cache::Module::Ancestor} subclass
  FACTORIES = [
      *NON_PAYLOAD_FACTORIES,
      *Metasploit::Cache::Payload::Ancestor::Spec::FACTORIES
  ].sort

  # Maps a {Metasploit::Cache::Module::Ancestor#module_type} to its {Metasploit::Cache::Module::Ancestor} subclass
  # factories.
  #
  # @example Using the module_type-specific factory
  #   let(:module_ancestor_factory) {
  #     Metasploit::Cache::Module::Ancestor::Spec::FACTORIES_BY_MODULE_TYPE.fetch(module_type).sample
  #   }
  #
  #   let(:module_type) {
  #     FactoryGirl.generate :metasploit_cache_module_type
  #   }
  FACTORIES_BY_MODULE_TYPE = {
      'auxiliary' => [
          :metasploit_cache_auxiliary_ancestor
      ],
      'encoder' => [
          :metasploit_cache_encoder_ancestor
      ],
      'exploit' => [
          :metasploit_cache_exploit_ancestor
      ],
      'nop' => [
          :metasploit_cache_nop_ancestor
      ],
      'payload' => Metasploit::Cache::Payload::Ancestor::Spec::FACTORIES,
      'post' => [
        :metasploit_cache_post_ancestor
      ]
  }

  # Maps a {Metasploit::Cache::Module::Ancestor} subclass factory to its
  # {Metasploit::Cache::Module::Ancestor#module_type}
  #
  # @example Using :metasploit_cache_module_ancestor_factory sequence to look up expected module_type
  #   let(:module_ancestor_factory) {
  #     FactoryGirl.generate :metasploit_cache_module_ancestor_factory
  #   }
  #
  #   let(:module_type) {
  #     Metasploit::Cache::Module::Ancestor::Spec::MODULE_TYPE_BY_FACTORY.fetch(module_ancestor_factory)
  #   }
  MODULE_TYPE_BY_FACTORY = {
      :metasploit_cache_auxiliary_ancestor => 'auxiliary',
      :metasploit_cache_encoder_ancestor => 'encoder',
      :metasploit_cache_exploit_ancestor => 'exploit',
      :metasploit_cache_nop_ancestor => 'nop',
      :metasploit_cache_payload_single_ancestor => 'payload',
      :metasploit_cache_payload_stage_ancestor => 'payload',
      :metasploit_cache_payload_stager_ancestor => 'payload',
      :metasploit_cache_post_ancestor => 'post'
  }

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

  # Stream of elements of {NON_PAYLOAD_FACTORIES}.
  #
  # @return [Enumerator<Symbol]
  def self.random_non_payload_factory
    Enumerator.new do |yielder|
      loop do
        yielder.yield NON_PAYLOAD_FACTORIES.sample
      end
    end
  end
end