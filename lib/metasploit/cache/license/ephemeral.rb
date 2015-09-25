# Helpers for synchronizing {Metasploit::Cache::License}s by {Metasploit::Cache::License#abbreviation}.
module Metasploit::Cache::License::Ephemeral
  # Maps {Metasploit::Cache::License#abbrevation} to {Metasploit::Cache::License} using pre-existing
  # {Metasploit::Cache::License} matching `existing_abbreviation_set`; otherwise, supplying new {Metasploit::Cache::License}s.
  #
  # @param existing_abbreviation_set [Set<String>] Set of {Metasploit::Cache::License#abbreviation} to preload
  # @return [Hash{String => Metasploit::Cache::License}]
  def self.by_abbreviation(existing_abbreviation_set:)
    Metasploit::Cache::Ephemeral::AttributeSet.existing_by_attribute_value(
        attribute: :abbreviation,
        scope: Metasploit::Cache::License,
        value_set: existing_abbreviation_set
    ).tap { |hash|
      hash.default_proc = Metasploit::Cache::Ephemeral.create_unique_proc(
          Metasploit::Cache::License,
          :abbreviation
      )
    }
  end
end