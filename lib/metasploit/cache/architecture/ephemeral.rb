# Helpers for synchronizing {Metasploit::Cache::Architecture}s by {Metasploit::Cache::Architecture#abbreviation}.
module Metasploit::Cache::Architecture::Ephemeral
  # Maps {Metasploit::Cache::Architecture#abbreviation} to {Metasploit::Cache::Architecture} using seeded
  # {Metasploit::Cache::Architecture} matching `existing_abbreviation_set`.
  #
  # @param existing_abbreviation_set [Set<String>] Set of {Metasploit::Cache::Architecture#abbreviation} to preload
  # @return [Hash{String => Metasploit::Cache::Architecture}]
  def self.by_abbreviation(existing_abbreviation_set:)
    if existing_abbreviation_set.empty?
      {}
    else
      Metasploit::Cache::Architecture.where(
          # AREL cannot visit Set
          abbreviation: existing_abbreviation_set.to_a
      ).each_with_object({}) { |architecture, architecture_by_abbreviation|
        architecture_by_abbreviation[architecture.abbreviation] = architecture
      }
    end
  end
end