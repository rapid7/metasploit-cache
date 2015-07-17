# Synchronizes the persistent cache of `#architecturable_architectures` with the in-memory `#arch` of Metasploit Module
# instances
module Metasploit::Cache::Architecturable::Ephemeral::ArchitecturableArchitectures
  #
  # Module Methods
  #

  # Builds new {Metasploit::Cache::Architecturable::Architecture} as `#architecturable_architectures` on `destination`
  #
  # @param destination [#architecturable_architectures]
  # @param destination_attribute_set [Set<String>] Set of {Metasploit::Cache::Architecture#abbreviation} on
  #   `#architecturable_architectures` on `destination`.
  # @param source_attribute_set [Set<String>] Set of `#arch` abbreviations from `source`.
  # @return [#architecturable_architectures] `destination`
  def self.build_added(destination:, destination_attribute_set:, source_attribute_set:)
    cached_added_attribute_set = Metasploit::Cache::Ephemeral::AttributeSet.added(
        destination: destination_attribute_set,
        source: source_attribute_set
    )

    cached_architecture_by_abbreviation = Metasploit::Cache::Ephemeral::AttributeSet.existing_by_attribute_value(
        attribute: :abbreviation,
        scope: Metasploit::Cache::Architecture,
        value_set: cached_added_attribute_set
    )

    cached_added_attribute_set.each do |added_architecture_abbreviation|
      architecture = cached_architecture_by_abbreviation[added_architecture_abbreviation]

      destination.architecturable_architectures.build(
          architecture: architecture
      )
    end

    destination
  end

  # The set of {Metasploit::Cache::Architecturable::Architecture#architecture}
  # {Metasploit::Cache::Architecture#abbrevation}  currently persisted as `#architecturable_architectures` on
  # `destination`.
  #
  # @param destination [#architecturable_architectures]
  # @return [Set<String>] Set of {Metasploit::Cache::Architecture#abbreviation}
  def self.destination_attribute_set(destination)
    if destination.new_record?
      Set.new
    else
      destination.architecturable_architectures.each_with_object(Set.new) do |architecturable_architecture, set|
        set.add architecturable_architecture.architecture.abbreviation
      end
    end
  end

  # Destroys {Metasploit::Cache::Architecturable::Architecture} `#architecturable_architectures` of
  # {Metasploit::Cache::Architecturable::Architecture#architecturable} `destination` that are persisted, but don't exist
  # in `source`.
  #
  # @param destination [#architecturable_architectures]
  # @param destination_attribute_set [Set<String>] Set of {Metasploit::Cache::Architecture#abbreviation} from
  #   `#architecturable_architecture` on `destination`.
  # @param source_attribute_set [Set<String>] Set of architecture abbreviations from `#arch` from `source`.
  # @return [#architecturable_architectures] `destination`
  def self.destroy_removed(destination:, destination_attribute_set:, source_attribute_set:)
    cached_removed_attribute_set = Metasploit::Cache::Ephemeral::AttributeSet.removed(
        destination: destination_attribute_set,
        source: source_attribute_set
    )

    unless destination.new_record? || cached_removed_attribute_set.empty?
      destination.architecturable_architectures.joins(
          :architecture
      ).where(
           Metasploit::Cache::Architecture.arel_table[:abbreviation].in(
               # AREL cannot visit Set
               cached_removed_attribute_set.to_a
           )
      ).readonly(false).destroy_all
    end

    destination
  end

  # The set of architecture abbreviations from `#arch` from the `source` Metasploit Module instance.
  #
  # @param source [#arch] Metasploit Module instance
  # @return [Set<String>] Set of architecture abbreviations
  def self.source_attribute_set(source)
    # It's always Enumerable, but not pluralized
    Set.new source.arch
  end

  # Synchronizes `#arch` from Metasploit Module instance `source` to persisted `#architecturable_architectures` on
  # {#destination}.
  #
  # @param destination [#architecturable_architectures] a {Metasploit::Cache::Architecturable::Architecture#architecturable}.
  # @param source [#arch] a Metasploit Module instance
  # @return [#architecturable_architectures] `destination`
  def self.synchronize(destination:, source:)
    Metasploit::Cache::Ephemeral.with_connection_transaction(destination_class: destination.class) {
      cached_destination_attributes_set = destination_attribute_set(destination)
      cached_source_attributes_set = source_attribute_set(source)

      [:destroy_removed, :build_added].reduce(destination) { |block_destination, method|
        public_send(
            method,
            destination: block_destination,
            destination_attribute_set: cached_destination_attributes_set,
            source_attribute_set: cached_source_attributes_set
        )
      }
    }
  end
end