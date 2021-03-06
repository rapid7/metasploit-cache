# Synchronizes the persistent cache of `#architecturable_architectures` with the in-memory `#arch` of Metasploit Module
# instances
module Metasploit::Cache::Architecturable::Persister::ArchitecturableArchitectures
  #
  # CONSTANTS
  #

  CANONICAL_ABBREVIATIONS_BY_SOURCE_ABBREVIATION = {
      'mips' => [
          'mipsbe',
          'mipsle'
      ],
      'x64' => [
          'x86_64'
      ]
  }

  # metasploit-framework Metasploit Modules without an 'Arch' are assumed to be 'x86' for historical reasons.
  DEFAULT_PRESENT_SOURCE_ATTRIBUTE_SET = Set.new(
      ['x86'.freeze]
  ).freeze

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
    cached_added_attribute_set = Metasploit::Cache::Persister::AttributeSet.added(
        destination: destination_attribute_set,
        source: source_attribute_set
    )

    cached_architecture_by_abbreviation = Metasploit::Cache::Persister::AttributeSet.existing_by_attribute_value(
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

  # Marks for destruction {Metasploit::Cache::Architecturable::Architecture} `#architecturable_architectures` of
  # {Metasploit::Cache::Architecturable::Architecture#architecturable} `destination` that are persisted, but don't exist
  # in `source`.
  #
  # @param destination [#architecturable_architectures]
  # @param destination_attribute_set [Set<String>] Set of {Metasploit::Cache::Architecture#abbreviation} from
  #   `#architecturable_architecture` on `destination`.
  # @param source_attribute_set [Set<String>] Set of architecture abbreviations from `#arch` from `source`.
  # @return [#architecturable_architectures] `destination`
  def self.mark_removed_for_destruction(destination:, destination_attribute_set:, source_attribute_set:)
    cached_removed_attribute_set = Metasploit::Cache::Persister::AttributeSet.removed(
        destination: destination_attribute_set,
        source: source_attribute_set
    )

    unless destination.new_record? || cached_removed_attribute_set.empty?
      destination.architecturable_architectures.each do |architecturable_architecture|
        if cached_removed_attribute_set.include? architecturable_architecture.architecture.abbreviation
          architecturable_architecture.mark_for_destruction
        end
      end
    end

    destination
  end

  # The set of architecture abbreviations that is guarenteed to be present.
  #
  # @param source (see source_attribute_set)
  # @param logger [ActiveSupport::TaggedLogger] logger tagged with {Metasploit::Cache::Module::Ancestor#real_pathname}.
  # @return [Set<'x86'>] if {source_attribute_set} is empty.
  # @return [Set<String>] {source_attribute_set} if {source_attribute_set} is present.
  def self.present_source_attribute_set(source, logger:)
    canonical_attribute_set = source_attribute_set(
        source,
        logger: logger
    )

    if canonical_attribute_set.present?
      canonical_attribute_set
    else
      logger.warn {
        "Has no 'Arch', so assuming 'x86'.  You should add 'Arch' => 'x86' to the module info Hash."
      }

      DEFAULT_PRESENT_SOURCE_ATTRIBUTE_SET
    end
  end

  # Reduces `destination` by
  # {marking for destruction the removed `#architecturable_architectures` mark_removed_for_destruction} and
  # {building the added `#architecturable_architectures` build_added}.
  #
  # @param destination [#architecturable_architectures] a {Metasploit::Cache::Architecturable::Architecture#architecturable}.
  # @param destination_attribute_set [Set<String>] Set of {Metasploit::Cache::Architecture#abbreviation}
  # @param source_attribute_set [Set<String>] Set of architecture abbreviations
  # @return [#architecturable_architectures] `destination`
  def self.reduce(destination:, destination_attribute_set:, source_attribute_set:)
    [:mark_removed_for_destruction, :build_added].reduce(destination) { |block_destination, method|
      public_send(
          method,
          destination: block_destination,
          destination_attribute_set: destination_attribute_set,
          source_attribute_set: source_attribute_set
      )
    }
  end

  # The set of architecture abbreviations from `#arch` from the `source` Metasploit Module instance.
  #
  # @param source [#arch] Metasploit Module instance
  # @param logger [ActiveSupport::TaggedLogger] logger already tagged with the
  #   {Metasploit::Cache::Module::Ancestor#real_pathname}.
  # @return [Set<String>] Set of architecture abbreviations
  def self.source_attribute_set(source, logger:)
    source.arch.each_with_object(Set.new) { |abbreviation, set|
      canonical_abbreviations = CANONICAL_ABBREVIATIONS_BY_SOURCE_ABBREVIATION[abbreviation]

      if canonical_abbreviations
        logger.warn {
          "Deprecated, non-canonical architecture abbreviation (#{abbreviation.inspect}) converted to canonical " \
          "abbreviations (#{canonical_abbreviations.inspect})"
        }

        set.merge(canonical_abbreviations)
      else
        set.add abbreviation
      end
    }
  end

  # Synchronizes `#arch` from Metasploit Module instance `source` to persisted `#architecturable_architectures` on
  # {#destination}.
  #
  # @param destination [#architecturable_architectures] a {Metasploit::Cache::Architecturable::Architecture#architecturable}.
  # @param logger [ActiveSupport::TaggedLogger] logger already tagged with
  #   {Metasploit::Cache::Module::Ancestor#real_pathname}.
  # @param source [#arch] a Metasploit Module instance
  # @return [#architecturable_architectures] `destination`
  def self.synchronize(destination:, logger:, source:)
    destination.class.connection_pool.with_connection {
      reduce(
          destination: destination,
          destination_attribute_set: destination_attribute_set(destination),
          source_attribute_set: present_source_attribute_set(
              source,
              logger: logger
          )
      )
    }
  end
end