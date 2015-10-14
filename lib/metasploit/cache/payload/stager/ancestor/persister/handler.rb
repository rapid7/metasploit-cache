# Synchronizes `#handler_type_alias` of payload stager Metasploit Module ruby Module to
# {Metasploit::Cache::Payload::Stager::Ancestor#handler} and
# {Metasploit::Cache::Payload::Stager::Ancestor::Handler#type_alias}.
module Metasploit::Cache::Payload::Stager::Ancestor::Persister::Handler
  # Builds {#handler} on `destination` if it currently doesn't have one, but `source` has `handler_type_alias`.
  #
  # @param destination [Metasploit::Cache::Payload::Stager::Ancestor, #handler]
  # @param destination_attributes [Hash{handler: nil}, Hash{handler: Hash{type_alias: String}}] `{handler: nil}` if
  #   `destination` has no handler.  `{handler: {type_alias: String}}` if `destination` has a handler type alias.
  # @param source_attributes [Hash{handler: nil}, Hash{handler: Hash{type_alias: String}}]  `{handler: nil}` if `source`
  #   does not respond to `#handler_type_alias`.  `{handler: {type_alias: handler_type_alias}}` otherwise.
  # @return [#handler] Updated `destination`
  def self.build_added(destination:, destination_attributes:, source_attributes:)
    unless destination_attributes.fetch(:handler)
      source_handler = source_attributes.fetch(:handler)

      if source_handler
        destination.build_handler(
            type_alias: source_handler.fetch(:type_alias)
        )
      end
    end

    destination
  end

  # Handler attributes for `destination`.
  #
  # @return [Hash{handler: nil}, Hash{handler: Hash{type_alias: String}}] `{handler: nil}` if
  #   `destination` has no handler.  `{handler: {type_alias: String}}` if `destination` has a handler type alias.
  def self.destination_attributes(destination)
    handler = destination.handler
    handler_attributes = nil

    if handler
      handler_attributes = {
          type_alias: handler.type_alias
      }
    end

    {
        handler: handler_attributes
    }
  end

  # Marks for destruction {#handler} on `destination` if it exists on {#destination}, but `source` doesn't respond to
  # `#handler_type_alias`.
  #
  # @param destination [Metasploit::Cache::Payload::Stager::Ancestor, #handler]
  # @param destination_attributes [Hash{handler: nil}, Hash{handler: Hash{type_alias: String}}] `{handler: nil}` if
  #   `destination` has no handler.  `{handler: {type_alias: String}}` if `destination` has a handler type alias.
  # @param source_attributes [Hash{handler: nil}, Hash{handler: Hash{type_alias: String}}]  `{handler: nil}` if `source`
  #   does not respond to `#handler_type_alias`.  `{handler: {type_alias: handler_type_alias}}` otherwise.
  # @return [#handler] Updated `destination`
  def self.mark_removed_for_destruction(destination:, destination_attributes:, source_attributes:)
    unless destination.new_record?
      if source_attributes.fetch(:handler).nil? && !destination_attributes.fetch(:handler).nil?
        destination.handler.mark_for_destruction
      end
    end

    destination
  end

  # Handler attributes for `source`.
  #
  # @param source [Module, #handler_type_alias] payload stager Metasploit Module ruby Module that MAY respond to
  #   `#handler_type_alias`.
  # @return [Hash{handler: nil}, Hash{handler: Hash{type_alias: String}}]  `{handler: nil}` if `source`
  #   does not respond to `#handler_type_alias`.  `{handler: {type_alias: handler_type_alias}}` otherwise.
  def self.source_attributes(source)
    handler_attributes = nil

    if source.respond_to? :handler_type_alias
      handler_attributes = {
          type_alias: source.handler_type_alias
      }
    end

    {
        handler: handler_attributes
    }
  end

  # Synchronizes `#handler_type_alia` from Metasploit Module ruby Module `source` to persisted
  # {Metasploit::Cache::Payload::Stager::Ancestor#handler} and
  # {Metasploit::Cache::Payload::Stager::Ancestor::Handler#type_alias}.
  #
  # @param destination [Metasploit::Cache::Payload::Stager::Ancestor, #handler]
  # @param logger [ActiveSupport::TaggedLogging] IGNORED
  # @param source [Module] payload stager Metasploit Module ruby Module that may respond to `#handler_type_alias`.
  # @return [Metasploit::Cache::Payload::Stager::Ancestor] Updated `destination`
  def self.synchronize(destination:, logger:, source:)
    cached_destination_attributes = destination_attributes(destination)
    cached_source_attributes = source_attributes(source)

    reduced = [:mark_removed_for_destruction, :update_changed, :build_added].reduce(destination) { |block_destination, method|
      public_send(
          method,
          destination: block_destination,
          destination_attributes: cached_destination_attributes,
          source_attributes: cached_source_attributes
      )
    }

    reduced
  end

  # If `destination` already has a {Metasploit::Cache::Payload::Stager::Ancestor#handler}, then update its
  # {Metasploit::Cache::Payload::Stager::Ancestor::Handler#type_alias} to match the `source` `handler_type_alias`.
  #
  # @param destination [Metasploit::Cache::Payload::Stager::Ancestor, #handler]
  # @param destination_attributes [Hash{handler: nil}, Hash{handler: Hash{type_alias: String}}] `{handler: nil}` if
  #   `destination` has no handler.  `{handler: {type_alias: String}}` if `destination` has a handler type alias.
  # @param source_attributes [Hash{handler: nil}, Hash{handler: Hash{type_alias: String}}]  `{handler: nil}` if `source`
  #   does not respond to `#handler_type_alias`.  `{handler: {type_alias: handler_type_alias}}` otherwise.
  # @return [#handler] Updated `destination`
  def self.update_changed(destination:, destination_attributes:, source_attributes:)
    if destination_attributes.fetch(:handler)
      source_handler = source_attributes.fetch(:handler)

      if source_handler
        destination.handler.type_alias = source_handler.fetch(:type_alias)
      end
    end

    destination
  end
end