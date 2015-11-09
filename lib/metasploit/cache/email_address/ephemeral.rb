# Helpers for synchronizing {Metasploit::Cache::EmailAddress}s by {Metasploit::Cache::EmailAddress#full}.
module Metasploit::Cache::EmailAddress::Ephemeral
  # Maps {Metasploit::Cache::EmailAddress#full} to {Metasploit::Cache::EmailAddress} using pre-existing
  # {Metasploit::Cache::EmailAddress} matching `full_set`; otherwise, supplying new {Metasploit::Cache::EmailAddress}s.
  #
  # @param existing_full_set [Set<String>] Set of {Metasploit::Cache::EmailAddress#full} to preload
  # @return [Hash{String => Metasploit::Cache::EmailAddress}]
  def self.by_full(existing_full_set:)
    Metasploit::Cache::Ephemeral::AttributeSet.existing_by_attribute_value(
        attribute: :full,
        scope: Metasploit::Cache::EmailAddress,
        value_set: existing_full_set).tap { |hash|
      hash.default_proc = Metasploit::Cache::Ephemeral.create_unique_proc(
          Metasploit::Cache::EmailAddress,
          :full
      )
    }
  end
end