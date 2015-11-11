# Builds name from Metasploit Module instance `source` to persisted `#name` on `destination`.
module Metasploit::Cache::Payload::Staged::Class::Persister::Name
  # Handler type from either handler module or the `#handler_type_alias` of the stager Module.
  #
  # @param destination [Metasploit::Cache::Payload::Staged::Class]
  # @return [String]
  def self.handler_type(destination:)
    payload_stager_instance = destination.payload_stager_instance
    payload_stager_ancestor_handler = payload_stager_instance.payload_stager_class.ancestor.handler

    if payload_stager_ancestor_handler
      payload_stager_ancestor_handler.type_alias
    else
      payload_stager_instance.handler.handler_type
    end
  end

  # Stage portion of the {Metasploit::Cache::Payload::Staged::Instance#name} that goes before the {handler_type}.
  #
  # @param destination [Metasploit::Cache::Payload::Staged::Class, #payload_stage_instance]
  # @return [String]
  def self.stage_name(destination:)
    Metasploit::Cache::Module::Class::Namable.reference_name(
        relative_file_names: destination.payload_stage_instance.payload_stage_class.ancestor.relative_file_names,
        scoping_levels: 2
    )
  end

  # Builds name from Metasploit Module instance `source` to persisted `#name` on `destination`.
  #
  # @param destination [ActiveRecord::Base, #name]
  # @param logger [ActiveSupport::TaggedLogger] IGNORED
  # @param source [Object] IGNORED
  # @return [#name] `destination`
  def self.synchronize(destination:, logger:, source:)
    stage_name = stage_name(destination: destination)
    handler_type = handler_type(destination: destination)

    destination.build_name(
        module_type: 'payload',
        reference: "#{stage_name}/#{handler_type}"
    )

    destination
  end
end