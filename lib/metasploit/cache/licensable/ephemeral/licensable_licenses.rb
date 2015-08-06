# Synchronizes the persistent cache of `#licensable_licenses` with the in-memory license, which is either a single
# `String` or `Array<String>` of the Metasploit Module instances.
module Metasploit::Cache::Licensable::Ephemeral::LicensableLicenses
  #
  # Module Methods
  #

  # Builds new `#licensable_licenses` on {Metasploit::Cache::Licensable::License#licensable} `destination`.
  #
  # @param destination [#licensable_licenses]
  # @param destination_attribute_set [Set<String>] Set of {Metasploit::Cache::License#abbreviation}s of `destination`'s
  #   `#licenses`.
  # @param source_attribute_set [Set<String>] Set of Metasploit Module instance's licenses.
  # @return [#licensable_licenses] `destination`
  def self.build_added(destination:, destination_attribute_set:, source_attribute_set:)
    cached_added_attribute_set = Metasploit::Cache::Ephemeral::AttributeSet.added(
        destination: destination_attribute_set,
        source: source_attribute_set
    )
    cached_license_by_abbreviation = Metasploit::Cache::License::Ephemeral.by_abbreviation(
        existing_abbreviation_set: cached_added_attribute_set
    )

    cached_added_attribute_set.each do |abbreviation|
      license = cached_license_by_abbreviation[abbreviation]

      destination.licensable_licenses.build(
          license: license
      )
    end

    destination
  end

  # The set of {Metasploit::Cache::License#abbreviations} on `destination`'s `#licenses`.
  #
  # @param destination [#licenses] Persistent cache of Metasploit Module instance
  # @return [Set<String>] Set of {Metasploit::Cache::License#abbreviations}
  def self.destination_attribute_set(destination)
    if destination.new_record?
      Set.new
    else
      Set.new destination.licenses.pluck(:abbreviation)
    end
  end

  # Marks for destruction {Metasploit::Cache::Licensable::License} `#licensable_licenses` of
  # {Metasploit::Cache::Licensable::License#licensable} `destination that are persisted, but don't exist in `source`.
  #
  # @param destination [#licensable_licenses]
  # @param destination_attribute_set [Set<String>] Set of {Metasploit::Cache::License#abbreviation} from
  #   {Metasploit::Cache::Licensable::License#license} from `#licensable_licenses` on `destination`.
  # @param source_attribute_set [Set<String>] Set of license abbreviations from `source` `#license`.
  def self.mark_removed_for_destruction(destination:, destination_attribute_set:, source_attribute_set:)
    cached_removed_attribute_set = Metasploit::Cache::Ephemeral::AttributeSet.removed(
        destination: destination_attribute_set,
        source: source_attribute_set
    )

    unless destination.new_record? || cached_removed_attribute_set.empty?
      destination.licensable_licenses.each do |licensable_license|
        if cached_removed_attribute_set.include? licensable_license.license.abbreviation
          licensable_license.mark_for_destruction
        end
      end
    end

    destination
  end

  # The set of license abbreviations from the `source` Metasploit Module instance
  #
  # @param source [#licenses] Metasploit Module instance
  # @return [Set<String>] Set of license abbreviations.
  def self.source_attribute_set(source)
    Set.new Array.wrap(source.license)
  end

  # Synchronizes license from Metasploit Module instance `source` to persisted `#licenses` on `destination`.
  #
  # @param destination [#licenses] a {Metasploit::Cache::Licensable::License#licensable}.
  # @param logger [ActiveSupport::TaggedLogger] logger already tagged with
  #   {Metasploit::Cache::Module::Ancestor#real_pathnam}.
  # @param source [#license] a Metasploit Module instance
  # @return [#licenses] `destination`
  def self.synchronize(destination:, logger:, source:)
    Metasploit::Cache::Ephemeral.with_connection_transaction(destination_class: destination.class) {
      cached_destination_attribute_set = destination_attribute_set(destination)
      cached_source_attribute_set = source_attribute_set(source)

      [:mark_removed_for_destruction, :build_added].reduce(destination) { |block_destination, method|
        public_send(
            method,
            destination: block_destination,
            destination_attribute_set: cached_destination_attribute_set,
            source_attribute_set: cached_source_attribute_set
        )
      }
    }
  end
end