# Helpers for synchronizing {Metasploit::Cache::Reference}s by {Metasploit::Cache::Reference#authority}
# {Metasploit::Cache::Authority#abbreviation} and {Metasploit::Cache::Reference#designation} or
# {Metasploit::Cache::Reference#url}.
module Metasploit::Cache::Reference::Ephemeral
  # Attributes Hash for looking up and synchronizing the `reference`.
  #
  # @return [Hash{authority: Hash{abbreviation: String}}] if `reference.authority` is set.
  # @return [Hash{url: String}] otherwise
  def self.attributes(reference)
    authority = reference.authority

    if authority
      {
          authority: {
              abbreviation: authority.abbreviation
          },
          designation: reference.designation
      }
      # don't use the reference.url since the metasploit-framework API doesn't support URLs for designations
    else
      # without an authority, only have the URL
      {
          url: reference.url
      }
    end
  end

  # Maps Hash of attributes to {Metasploit::Cache::Reference} using pre-existing
  # {Metasploit::Cache::Reference} matching `attributes_set`; otherwise, supplying new {Metasploit::Cache::Reference}s.
  #
  # @param attributes_set [Set<Hash{authority: Hash{abbreviation: String}, designation: String}, Hash{url: String}>]
  #   Set of {Metasploit::Cache::Reference#authority} {Metasploit::Cache::Authority#abbreviation} and
  #   {Metasploit::Cache::Reference#designation} or {Metasploit::Cache::Reference#url} to preload
  # @param authority_by_abbreviation [Hash{String => Metasploit::Cache::Authority}] Maps
  #   {Metasploit::Cache::Authority#abbreviation} to {Metasploit::Cache::Authority} for {Metasploit::Cache::Reference}
  #   look-up in {existing_by_attributes} and initialization in {new_by_attributes_proc}.
  # @return [Hash{Hash{authority: Hash{abbreviation: String}, designation: String}, Hash{url: String} => Metasploit::Cache::Reference}]
  def self.by_attributes(attributes_set:, authority_by_abbreviation:)
    existing_by_attributes(
        attributes_set: attributes_set,
        authority_by_abbreviation: authority_by_abbreviation
    ).tap { |hash|
      hash.default_proc = new_by_attributes_proc(authority_by_abbreviation: authority_by_abbreviation)
    }
  end

  # Where condition(s) to find the {Metasploit::Cache::Reference} with the given attributes
  #
  #
  # @param attributes [Hash{authority: Hash{abbreviation: String}, designation: String}, Hash{url: String}]
  #   {Metasploit::Cache::Reference#authority} {Metasploit::Cache::Authority#abbreviation} and
  #   {Metasploit::Cache::Reference#designation} or {Metasploit::Cache::Reference#url}
  # @param authority_by_abbreviation [Hash{String => Metasploit::Cache::Authority}] Maps
  #   {Metasploit::Cache::Authority#abbreviation} to {Metasploit::Cache::Authority} for {Metasploit::Cache::Reference}
  #   look-up.
  # @return [Arel::Nodes::Node] condition that can be used in `ActiveRecord::Relation#where`.
  # @return [nil] if `attributes[:authority][:abbreviation]` is not a key in `authority_by_abbreviation`.
  def self.condition(attributes:, authority_by_abbreviation:)
    attributes_condition = nil
    authority_attributes = attributes[:authority]

    # if has authority
    if authority_attributes
      abbreviation = authority_attributes.fetch(:abbreviation)
      authority = authority_by_abbreviation[abbreviation]

      if authority
        authority_id_condition = Metasploit::Cache::Reference.arel_table[:authority_id].eq(authority.id)

        designation = attributes.fetch(:designation)
        designation_condition = Metasploit::Cache::Reference.arel_table[:designation].eq(designation)

        attributes_condition = authority_id_condition.and(designation_condition)
      end
    else
      url = attributes.fetch(:url)
      attributes_condition = Metasploit::Cache::Reference.arel_table[:url].eq(url)
    end

    attributes_condition
  end

  # Where conditions to find the {Metasploit::Cache::Reference}s with the given attributes.
  #
  # @param attributes_set [Set<Hash{authority: Hash{abbreviation: String}, designation: String}, Hash{url: String}>]
  #   Set of {Metasploit::Cache::Reference#authority} {Metasploit::Cache::Authority#abbreviation} and
  #   {Metasploit::Cache::Reference#designation} or {Metasploit::Cache::Reference#url}
  # @param authority_by_abbreviation [Hash{String => Metasploit::Cache::Authority}] Maps
  #   {Metasploit::Cache::Authority#abbreviation} to {Metasploit::Cache::Authority} for {Metasploit::Cache::Reference}
  #   look-up.
  # @return [Array<Arel::Nodes::Node>] conditions that can be used in `ActiveRecord::Relation#where`.
  def self.conditions(attributes_set:, authority_by_abbreviation:)
    attributes_set.each_with_object([]) do |attributes, reference_conditions|
      attributes_condition = condition(attributes: attributes, authority_by_abbreviation: authority_by_abbreviation)

      if attributes_condition
        reference_conditions << attributes_condition
      end
    end
  end

  # The `where` conditions used to look up the {Metasploit::Cache::Reference}s with the given `Set` of {attributes}.
  #
  # @retun

  # Maps {Metasploit::Cache::Reference#authority} {Metasploit::Cache::Authority#abbreviation} and
  # {Metasploit::Cache::Reference#designation} or {Metasploit::Cache::Reference#url} to existing
  # {Metasploit::Cache::Reference}.
  #
  # @param attributes_set [Set<Hash{authority: Hash{abbreviation: String}, designation: String}, Hash{url: String}>]
  #   Set of {Metasploit::Cache::Reference#authority} {Metasploit::Cache::Authority#abbreviation} and
  #   {Metasploit::Cache::Reference#designation} or {Metasploit::Cache::Reference#url}
  # @param authority_by_abbreviation [Hash{String => Metasploit::Cache::Authority}] Maps
  #   {Metasploit::Cache::Authority#abbreviation} to {Metasploit::Cache::Authority} for {Metasploit::Cache::Reference}
  #   look-up.
  # @return [Hash{Hash{authority: Hash{abbreviation: String}, designation: String}, Hash{url: String} => Metasploit::Cache::Reference}]
  def self.existing_by_attributes(attributes_set:, authority_by_abbreviation:)
    # avoid querying database with `IN (NULL)`
    if attributes_set.empty?
      {}
    else
      cached_conditions = conditions(
          attributes_set: attributes_set,
          authority_by_abbreviation: authority_by_abbreviation
      )
      cached_unioned_conditions = union_conditions(cached_conditions)
      # get pre-existing references in bulk
      Metasploit::Cache::Reference.references(:authority).where(
          cached_unioned_conditions
      ).each_with_object({}) do |reference, reference_by_attributes|
        attributes = attributes(reference)

        reference_by_attributes[attributes] = reference
      end
    end
  end

  # Maps Hash of {Metasploit::Cache::Reference#authority} {Metasploit::Cache::Authority#abbreviation} and
  # {Metasploit::Cache::Reference#designation} or {Metasploit::Cache::Reference#url} to new
  # {Metasploit::Cache::Reference}.
  #
  # @param authority_by_abbreviation [Hash{String => Metasploit::Cache::Authority}] Maps
  #   {Metasploit::Cache::Authority#abbreviation} to {Metasploit::Cache::Authority} to look-up
  #   {Metasploit::Cache::Reference#authority}
  # @return [Proc<<Hash{authority: Hash{abbreviation: String}, designation: String}, Hash{url: String}>, String>]
  def self.new_by_attributes_proc(authority_by_abbreviation:)
    ->(hash, attributes) {
      authority_attributes = attributes[:authority]

      if authority_attributes
        authority = authority_by_abbreviation[authority_attributes.fetch(:abbreviation)]

        hash[attributes] = Metasploit::Cache::Reference.new(
            authority: authority,
            designation: attributes.fetch(:designation)
        )
      else
        hash[attributes] = Metasploit::Cache::Reference.new(
            url: attributes.fetch(:url)
        )
      end
    }
  end

  # Union of all `conditions`.
  #
  # @param conditions [Enumerable<Arel::Nodes::Node>] conditions to be ORed together.
  # @return [Arel::Nodes::Node]
  def self.union_conditions(conditions)
    conditions.reduce(:or)
  end
end