# Helpers for synchronizing {Metasploit::Cache::Architecture}s by {Metasploit::Cache::Architecture#abbreviation}.
module Metasploit::Cache::Architecture::Ephemeral
  # Maps {Metasploit::Cache::Architecture#abbreviation} to {Metasploit::Cache::Architecture} using seeded
  # {Metasploit::Cache::Architecture} matching `existing_abbreviation_set`.
  #
  # @param existing_abbreviation_set [Set<String>] Set of {Metasploit::Cache::Architecture#abbreviation} to preload
  # @return [Hash{String => Metasploit::Cache::Architecture}]
  def self.by_abbreviation(existing_abbreviation_set:)
    Metasploit::Cache::Ephemeral::AttributeSet.existing_by_attribute_value(
        attribute: :abbreviation,
        scope: Metasploit::Cache::Architecture,
        value_set: existing_abbreviation_set
    )
  end
end