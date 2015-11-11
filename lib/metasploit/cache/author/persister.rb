# Helpers for synchronizing {Metasploit::Cache::Author}s by {Metasploit::Cache::Author#name}.
module Metasploit::Cache::Author::Persister
  # Maps {Metasploit::Cache::Author#name} to {Metasploit::Cache::Author} using pre-existing {Metasploit::Cache::Author}
  # matching `name_set`; otherwise, supplying newly created {Metasploit::Cache::Author}s.
  #
  # @param existing_name_set [Set<String>] Set of {Metasploit::Cache::Author#name} to preload
  # @return [Hash{String => Metasploit::Cache::Author}]
  def self.by_name(existing_name_set:)
    Metasploit::Cache::Persister::AttributeSet.existing_by_attribute_value(
        attribute: :name,
        scope: Metasploit::Cache::Author,
        value_set: existing_name_set
    ).tap { |hash|
      hash.default_proc = Metasploit::Cache::Persister.create_unique_proc(
          Metasploit::Cache::Author,
          :name
      )
    }
  end
end