# Helpers for synchronizing {Metasploit::Cache::License}s by {Metasploit::Cache::License#abbreviation}.
module Metasploit::Cache::License::Ephemeral
  # Maps {Metasploit::Cache::License#abbrevation} to {Metasploit::Cache::License} using pre-existing
  # {Metasploit::Cache::License} matching `existing_abbreviation_set`; otherwise, supplying new {Metasploit::Cache::License}s.
  #
  # @param existing_abbreviation_set [Set<String>] Set of {Metasploit::Cache::License#abbreviation} to preload
  # @return [Hash{String => Metasploit::Cache::License}]
  def self.by_abbreviation(existing_abbreviation_set:)
    existing_by_abbreviation(abbreviation_set: existing_abbreviation_set).tap { |hash|
      hash.default_proc = Metasploit::Cache::Ephemeral.create_unique_proc(
          Metasploit::Cache::License,
          :abbreviation
      )
    }
  end

  # Maps {Metasploit::Cache::License#abbreviation} to existing {Metasploit::Cache::License}.
  #
  # @param abbreviation_set [Set<String>] Set of license abbreviations from added attributes set.
  # @return [Hash{String => Metasploit::Cache::License}]
  def self.existing_by_abbreviation(abbreviation_set:)
    # avoid querying database with `IN (NULL)`
    if abbreviation_set.empty?
      {}
    else
      # get pre-existing licenses in bulk
      Metasploit::Cache::License.where(
          # AREL cannot visit Set
          abbreviation: abbreviation_set.to_a
      ).each_with_object({}) { |license, license_by_abbreviation|
        license_by_abbreviation[license.abbreviation] = license
      }
    end
  end
end