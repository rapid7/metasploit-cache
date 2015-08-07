# Synchronizes the persistent cache of `#referencable_references` with the in-memory `#references` of Metasploit Module
# instances.
module Metasploit::Cache::Referencable::Ephemeral::ReferencableReferences
  #
  # Module Methods
  #

  # Extracts set of {Metasploit::Cache::Authority#abbreviation} from `Set` of attribute `Hash`es.
  #
  # @param attributes_set [Set<Hash{authority: Hash{abbreviation: String}}>] Set of Hashes of with or without
  #   `{authority: {abbreviation: Metasploit::Cache::Authority#abbreviation}}`
  # @return [Set<String>] Does not contain `nil`s
  def self.authority_abbreviation_set(attributes_set)
    attributes_set.each_with_object(Set.new) do |attributes, set|
      authority_attributes = attributes[:authority]

      if authority_attributes
        set.add authority_attributes.fetch(:abbreviation)
      end
    end
  end

  # Maps {Metasploit::Cache::Authority#abbreviation} to seeded {Metasploit::Cache::Authority}.
  #
  # @param attributes_set [Set<Hash{authority: Hash{abbreviation: String}}>] Set of Hashes of with or without
  #   `{authority: {abbreviation: Metasploit::Cache::Authority#abbreviation}}`
  # @return [Hash{String => Metasploit::Cache::Authority}]
  def self.authority_by_abbreviation(attributes_set)
    abbreviation_set = authority_abbreviation_set(attributes_set)

    Metasploit::Cache::Ephemeral::AttributeSet.existing_by_attribute_value(
        attribute: :abbreviation,
        scope: Metasploit::Cache::Authority,
        value_set: abbreviation_set
    )
  end

  # Builds new {Metasploit::Cache::Referencable::Reference} as `#referencable_references` on `destination`
  #
  # @param destination [#referencable_references]
  # @param destination_attributes_set [Set<Hash{authority: Hash{abbreviation: String}, destination: String}, Hash{url: String}>]
  #   Set of Hashes of either
  #   `{authority: {abbreviation: Metasploit::Cache::Authority#abbreviation}, designation: Metasploit::Cache::Reference#designation}`
  #   or `{url: Metasploit::Cache::Reference#url}` on `destination`.
  # @param logger (see Metasploit::Cache::Reference::Ephemeral.new_by_attributes_proc)
  # @param source_attributes_set [Set<Hash{authority: Hash{abbreviation: String}, destination: String}, Hash{url: String}>]
  #   Set of Hashes of either `{authority: {abbreviation: ctx_id}, designation: ctx_val}` or `{url: ctx_val}` of
  #   `references` of `source`.
  # @return [#referencable_references] `destination`
  def self.build_added(destination:, destination_attributes_set:, logger:, source_attributes_set:)
    cached_added_attributes_set = Metasploit::Cache::Ephemeral::AttributeSet.added(
        destination: destination_attributes_set,
        source: source_attributes_set
    )

    cached_authority_by_abbreviation = authority_by_abbreviation(cached_added_attributes_set)
    cached_reference_by_attributes = Metasploit::Cache::Reference::Ephemeral.by_attributes(
        attributes_set: cached_added_attributes_set,
        authority_by_abbreviation: cached_authority_by_abbreviation,
        logger: logger
    )

    cached_added_attributes_set.each do |attributes|
      reference = cached_reference_by_attributes[attributes]

      destination.referencable_references.build(
          reference: reference
      )
    end

    destination
  end

  # The set of {Metasploit::Cache::Referencable::Reference#reference} {Metasploit::Cache::Reference#designation} and
  # {Metasploit::Cache::Reference#authority} {Metasploit::Cache::Authority#abbreviation} or
  # {Metasploit::Cache::Reference#url} currently persisted as `#referencable_references` on `destination`.
  #
  # @param referencable_reference_by_attributes [Hash{Hash{authority: Hash{abbreviation: String}, destination: String}, Hash{url: String} => Metasploit::Cache::Referencable::Reference}]
  #   Keys will be used as returned set.
  # @return [Set<Hash{authority: Hash{abbreviation: String}, destination: String}, Hash{url: String}>]
  #   Set of Hashes of either
  #   `{authority: {abbreviation: Metasploit::Cache::Authority#abbreviation}, designation: Metasploit::Cache::Reference#designation}`
  #   or `{url: Metasploit::Cache::Reference#url}` on `destination`.
  def self.destination_attributes_set(referencable_reference_by_attributes)
    Set.new referencable_reference_by_attributes.each_key
  end

  # Marks for destruction {Metasploit::Cache::Referencable::Reference} `#referencable_reference` of
  # {Metasploit::Cache::Platformable::Platform#platformable} `destination` that are persisted, but don't exist in
  # `source`.
  #
  # @param destination [#referencable_references]
  # @param destination_attributes_set [Set<Hash{authority: Hash{abbreviation: String}, destination: String}, Hash{url: String}>]
  #   Set of Hashes of either
  #   `{authority: {abbreviation: Metasploit::Cache::Authority#abbreviation}, designation: Metasploit::Cache::Reference#designation}`
  #   or `{url: Metasploit::Cache::Reference#url}` on `destination`.
  # @param referencable_reference_by_attributes [Hash{Hash{authority: Hash{abbreviation: String}, destination: String}, Hash{url: String} => Metasploit::Cache::Referencable::Reference}]
  #   Maps attributes in `destination_attributes_set` to their originating {Metasploit::Cache::Referencable::Reference}
  #   from `#referencable_references` of `destination`.
  # @param source_attributes_set [Set<Hash{authority: Hash{abbreviation: String}, destination: String}, Hash{url: String}>]
  #   Set of Hashes of either `{authority: {abbreviation: ctx_id}, designation: ctx_val}` or `{url: ctx_val}` of
  #   `references` of `source`.
  # @return [#referencable_references] `destination`
  def self.mark_removed_for_destruction(destination:, destination_attributes_set:, referencable_reference_by_attributes:, source_attributes_set:)
    cached_removed_attribute_set = Metasploit::Cache::Ephemeral::AttributeSet.removed(
        destination: destination_attributes_set,
        source: source_attributes_set
    )

    unless destination.new_record? || cached_removed_attribute_set.empty?
      cached_removed_attribute_set.each do |attributes|
        referencable_reference = referencable_reference_by_attributes.fetch(attributes)

        referencable_reference.mark_for_destruction
      end
    end

    destination
  end

  # Maps {Metasploit::Cache::Reference#authority} {Metasploit::Cache::Authority#abbreviation} and
  # {Metasploit::Cache::Reference#destination} or {Metasploit::Cache::Reference#url} to
  # {Metasploit::Cache::Referencable::Reference} `#referencable_references` on `destination`.
  #
  # @param destination [#referencable_references]
  # @return [Hash{Hash{authority: Hash{abbreviation: String}, destination: String}, Hash{url: String} => Metasploit::Cache::Referencable::Reference}]
  def self.referencable_reference_by_attributes(destination)
    if destination.new_record?
      {}
    else
      destination.referencable_references.each_with_object({}) do |referencable_reference, hash|
        reference = referencable_reference.reference
        attributes = Metasploit::Cache::Reference::Ephemeral.attributes(reference)

        hash[attributes] = referencable_reference
      end
    end
  end

  # The set of reference attributes from `#references` on the `source` Metasploit Module instance.
  #
  # @param source [#references] Metasploit Module instance
  # @return [Set<Hash{authority: Hash{abbreviation: String}, destination: String}, Hash{url: String}>] Set of Hashes of
  #   either `{authority: {abbreviation: ctx_id}, designation: ctx_val}` or `{url: ctx_val}` of `#references` of
  #   `source`.
  def self.source_attributes_set(source)
    source.references.each_with_object(Set.new) { |reference, set|
      if reference.ctx_id == 'URL'
        attributes = {
            url: reference.ctx_val
        }
      else
        attributes = {
            authority: {
                abbreviation: reference.ctx_id
            },
            designation: reference.ctx_val
        }
      end

      set.add attributes
    }
  end

  # Synchronizes `#references` from Metasploit Module instance `source` to persisted `#referencable_references` on
  # {#destination}.
  #
  # @param destination [#referencable_references] a {Metasploit::Cache::Referencable::Reference#referencable}.
  # @param logger [ActiveSupport::TaggedLogger] logger already tagged with
  #   {Metasploit::Cache::Module::Ancestor#real_pathnam}.
  # @param source [#references] a Metasploit Module instance
  # @return [#referencable_references] `destination`
  def self.synchronize(destination:, logger:, source:)
    Metasploit::Cache::Ephemeral.with_connection_transaction(destination_class: destination.class) {
      cached_referencable_reference_by_attributes = referencable_reference_by_attributes(destination)
      cached_destination_attributes_set = destination_attributes_set(cached_referencable_reference_by_attributes)
      cached_source_attributes_set = source_attributes_set(source)

      marked = mark_removed_for_destruction(
          destination: destination,
          destination_attributes_set: cached_destination_attributes_set,
          referencable_reference_by_attributes: cached_referencable_reference_by_attributes,
          source_attributes_set: cached_source_attributes_set
      )
      build_added(
          destination: marked,
          destination_attributes_set: cached_destination_attributes_set,
          source_attributes_set: cached_source_attributes_set,
          logger: logger
      )
    }
  end
end