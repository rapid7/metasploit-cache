# Builds name from Metasploit Module instance `source` to persisted `#name` on `destination`.
module Metasploit::Cache::Direct::Class::Persister::Name
  # Builds name from Metasploit Module instance `source` to persisted `#name` on `destination`.
  #
  # @param destination [ActiveRecord::Base, #name]
  # @param logger [ActiveSupport::TaggedLogger] IGNORED
  # @param source [Object] IGNORED
  # @return [#name] `destination`
  def self.synchronize(destination:, logger:, source:)
    destination.build_name(
        module_type: destination.class::MODULE_TYPE,
        reference: destination.reference_name
    )

    destination
  end
end