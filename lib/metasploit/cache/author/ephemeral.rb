# Helpers for synchronizing {Metasploit::Cache::Author}s by {Metasploit::Cache::Author#name}.
module Metasploit::Cache::Author::Ephemeral
  # Maps {Metasploit::Cache::Author#name} to {Metasploit::Cache::Author} using pre-existing {Metasploit::Cache::Author}
  # matching `name_set`; otherwise, supplying newly created {Metasploit::Cache::Author}s.
  #
  # @param existing_name_set [Set<String>] Set of {Metasploit::Cache::Author#name} to preload
  # @return [Hash{String => Metasploit::Cache::Author}]
  def self.by_name(existing_name_set:)
    existing_by_name(name_set: existing_name_set).tap { |hash|
      hash.default_proc = create_by_name_proc
    }
  end

  # Maps {Metasploit::Cache::Author#name} to newly created {Metasploit::Cache::Author}.
  #
  # @return [Proc<Hash, String>]
  def self.create_by_name_proc
    ->(hash, name) {
      # create! to prevent race condition when two threads, such as auxiliary and exploit are creating instances
      # with the same author.  Race condition manifests as errors like
      #
      #     PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint "index_mc_authors_on_name"
      #     DETAIL:  Key (name)=(hdm) already exists.
      #     : INSERT INTO "mc_authors" ("name") VALUES ($1) RETURNING "id"
      hash[name] = Metasploit::Cache::Author.create!(name: name)
    }
  end

  # Maps {Metasploit::Cache::Author#name} to existing {Metasploit::Cache::Author}.
  #
  # @param name_set [Set<String>] Set of author names from added attributes set.
  # @return [Hash{String => Metasploit::Cache::Author}]
  def self.existing_by_name(name_set:)
    # avoid querying database with `IN (NULL)`
    if name_set.empty?
      {}
    else
      # get pre-existing authors in bulk
      Metasploit::Cache::Author.where(
          # AREL cannot visit Set
          name: name_set.to_a
      ).each_with_object({}) { |author, author_by_name|
        author_by_name[author.name] = author
      }
    end
  end
end