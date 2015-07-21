# Helpers for synchronizing {Metasploit::Cache::EmailAddress}s by {Metasploit::Cache::EmailAddress#full}.
module Metasploit::Cache::EmailAddress::Ephemeral
  # Maps {Metasploit::Cache::EmailAddress#full} to {Metasploit::Cache::EmailAddress} using pre-existing
  # {Metasploit::Cache::EmailAddress} matching `full_set`; otherwise, supplying new {Metasploit::Cache::EmailAddress}s.
  #
  # @param existing_full_set [Set<String>] Set of {Metasploit::Cache::EmailAddress#full} to preload
  # @return [Hash{String => Metasploit::Cache::EmailAddress}]
  def self.by_full(existing_full_set:)
    existing_by_full(full_set: existing_full_set).tap { |hash|
      hash.default_proc = new_by_full_proc
    }
  end

  # Maps {Metasploit::Cache::Author#full} to existing {Metasploit::Cache::EmailAddress}.
  #
  # @param full_set [Set<String>] Set of full email address from added attributes set.
  # @return [Hash{String => Metasploit::Cache::EmailAddress}]
  def self.existing_by_full(full_set:)
    if full_set.empty?
      {}
    else
      Metasploit::Cache::EmailAddress.where(
          # AREL cannot visit Set
          full: full_set.to_a
      ).each_with_object({}) { |email_address, email_address_by_full|
        email_address_by_full[email_address.full] = email_address
      }
    end
  end

  # Maps {Metasploit::Cache::EmailAddress#full} to new {Metasploit::Cache::EmailAddress}.
  #
  # @return [Proc<Hash, String>]
  def self.new_by_full_proc
    ->(hash, full) {
      hash[full] = Metasploit::Cache::EmailAddress.new(full: full)
    }
  end
end