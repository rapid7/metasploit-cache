# Synchronizes the persistent cache of `#platformable_platforms` with the in-memory `#platforms` of `#platform` of
# Metasploit Module instances.
module Metasploit::Cache::Platformable::Ephemeral::PlatformablePlatforms
  #
  # CONSTANTS
  #

  # `#realname` use for source platforms to indicate all platforms are supported.
  SOURCE_ANY_PLATFORM_REALNAME = ''

  #
  # Module Methods
  #

  # Whether the `source_platforms` represents the source support any platform.
  #
  # @return [true] any platform is supported.
  # @return [false] only specific platforms are supported.
  def self.any_source_platform?(source_platforms)
    source_platforms.length == 1 && source_platforms[0].realname == SOURCE_ANY_PLATFORM_REALNAME
  end

  # Builds new {Metasploit::Cache::Platformable::Platform} as `#platformable_platforms` on `destination`
  #
  # @param destination [#platformable_platforms]
  # @param destination_attribute_set [Set<String>] Set of {Metasploit::Cache::Platform#platform} on
  #   `#platformable_platforms` on `destination`.
  # @param source_attribute_set [Set<String>] Set of `#realname` of `#platforms` of `#platform` of `source`.
  # @return [#platformable_platforms] `destination`
  def self.build_added(destination:, destination_attribute_set:, source_attribute_set:)
    cached_added_attribute_set = Metasploit::Cache::Ephemeral::AttributeSet.added(
        destination: destination_attribute_set,
        source: source_attribute_set
    )

    cached_platform_by_fully_qualified_name = Metasploit::Cache::Ephemeral::AttributeSet.existing_by_attribute_value(
        attribute: :fully_qualified_name,
        scope: Metasploit::Cache::Platform,
        value_set: cached_added_attribute_set
    )

    cached_added_attribute_set.each do |added_fully_qualified_name|
      platform = cached_platform_by_fully_qualified_name[added_fully_qualified_name]

      destination.platformable_platforms.build(
          platform: platform
      )
    end

    destination
  end

  # The set of {Metasploit::Cache::Platformable::Plaform#platform} {Metasploit::Cache::Platform#fully_qualified_name}
  # currently persisted as `#platformable_platforms` on `destination`.
  #
  # @param destination [#platformable_platforms]
  # @return [Set<String>] Set of {Metasploit::Cache::Platform#fully_qualified_name}
  def self.destination_attribute_set(destination)
    if destination.new_record?
      Set.new
    else
      destination.platformable_platforms.each_with_object(Set.new) do |platformable_platform, set|
        set.add platformable_platform.platform.fully_qualified_name
      end
    end
  end

  # Destroys {Metasploit::Cache::Platformable::Platform} `#platformable_platforms` of
  # {Metasploit::Cache::Platformable::Platform#platformable} `destination` that are persisted, but don't exist in
  # `source`.
  #
  # @param destination [#platformable_platforms]
  # @param destination_attribute_set [Set<String>] Set of {Metasploit::Cache::Platform#fully_qualified_name} from
  #   `#platformable_platforms` on `destination`.
  # @param source_attribute_set [Set<String>] Set of platform full names from `#platform` from `source`.
  # @return [#platformable_platforms] `destination`
  def self.destroy_removed(destination:, destination_attribute_set:, source_attribute_set:)
    cached_removed_attribute_set = Metasploit::Cache::Ephemeral::AttributeSet.removed(
        destination: destination_attribute_set,
        source: source_attribute_set
    )

    unless destination.new_record? || cached_removed_attribute_set.empty?
      destination.platformable_platforms.joins(
          :platform
      ).where(
           Metasploit::Cache::Platform.arel_table[:fully_qualified_name].in(
               # AREL cannot visit Set
               cached_removed_attribute_set.to_a
           )
      ).readonly(false).destroy_all
    end

    destination
  end

  # @note If `source` `#platform` `#platforms` contains a single entry that is just `''`, then it is assumed to mean all
  #   platforms and the {Metasploit::Cache::Platform.root_fully_qualified_name_set} will be returned.
  #
  # The set of platform fully qualified names from `#platforms` on `#platform` on the `source` Metasploit Module
  # instance.
  #
  # @param source [#platform] Metasploit Module instance
  # @return [Set<String>] Set of platform fully-qualified names
  def self.source_attribute_set(source)
    source_platforms = source.platform.platforms

    if any_source_platform?(source_platforms)
      platform_fully_qualified_name_set = Metasploit::Cache::Platform.root_fully_qualified_name_set
    else
      platform_fully_qualified_name_set = source_platforms.each_with_object(Set.new) { |platform, set|
        set.add platform.realname
      }
    end

    platform_fully_qualified_name_set
  end

  # Synchronizes `#platforms` from `#platform` from Metasploit Module instance `source` to persisted
  # `#platformable_platforms` on {#destination}.
  #
  # @param destination [#platformable_platforms] a {Metasploit::Cache::Platformable::Platform#platformable}.
  # @param source [#platform] a Metasploit Module instance
  # @return [#platformable_platforms] `destination`
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