# Builds a new {Metasploit::Cache::Payload::Handler} if one does not exist with the given
# {Metasploit::Cache::Payload::Handler#general_handler_type} and {Metasploit::Cache::Payload::Handler#handler_type} or
# uses the pre-existing {Metasploit::Cache::Payload::Handler} with those attributes as the `#handler` for the
# destination.
module Metasploit::Cache::Payload::Handable::Persister::Handler
  # Attributes of `destination.handler`.
  #
  # @param destination (see synchronize)
  # @return [{}] if `destination` is a new record
  # @return [{general_handler_type: String, handler_type: String}] if `destination` is persisted
  def self.destination_attributes(destination)
    if destination.new_record?
      {}
    else
      Metasploit::Cache::Payload::Handler::Persister.attributes(destination.handler)
    end
  end

  # Attributes for `source.handler_klass`
  #
  # @param source (see synchronize)
  # @return [{general_handler_type: String, handler_type: String}]
  def self.source_attributes(source)
    Metasploit::Cache::Payload::Handler::Persister.attributes(source.handler_klass)
  end

  # Synchronizes the `#handler_klass` from single or stager payload Metasploit Module instance `source` to persisted
  # {Metasploit::Cache::Payload::Single::Unhandled::Instance#handler} or {Metasploit::Cache::Payload::Stager::Instance#handler} on
  # `destination`.
  #
  # @param destination [Metasploit::Cache::Payload::Single::Unhandled::Instance, Metasploit::Cache::Payload::Stager::Instance, #handler]
  # @param logger [ActiveSupport::TaggedLogger] logger already tagged with
  #   {Metasploit::Cache::Module::Ancestor#real_pathname}.
  # @param source [#handler_klass]
  # @return [Metasploit::Cache::Payload::Single::Unhandled::Instance, Metasploit::Cache::Payload::Stager::Instance, #handler]
  #   `destination`
  def self.synchronize(destination:, logger:, source:)
    destination.class.connection_pool.with_connection {
      cached_destination_attributes = destination_attributes(destination)
      cached_source_attributes = source_attributes(source)

      if cached_destination_attributes != cached_source_attributes
        payload_handler = Metasploit::Cache::Payload::Handler.isolation_level(:serializable) {
          Metasploit::Cache::Payload::Handler.transaction {
            destination.handler = Metasploit::Cache::Payload::Handler.where(cached_source_attributes).first_or_create!
          }
        }

        destination.handler = payload_handler
      end
    }

    destination
  end
end
