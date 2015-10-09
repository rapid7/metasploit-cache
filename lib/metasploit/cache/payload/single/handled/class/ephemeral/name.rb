# Builds name from Metasploit Module instance `source` to persisted `#name` on `destination`.
module Metasploit::Cache::Payload::Single::Handled::Class::Ephemeral::Name
  # Builds name from Metasploit Module instance `source` to persisted `#name` on `destination`.
  #
  # @param destination [ActiveRecord::Base, #name]
  # @param logger [ActiveSupport::TaggedLogger] IGNORED
  # @param source [Object] IGNORED
  # @return [#name] `destination`
  def self.synchronize(destination:, logger:, source:)
    destination.build_name(
        module_type: 'payload',
        reference: destination.reference_name
    )

    destination
  end
end