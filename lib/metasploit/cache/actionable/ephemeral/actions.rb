# Synchronizes the persistent cache of {Metasploit::Cache::Actionable::Action#actionable} `actions with the in-memory
# actions on a Metasploit Module instance.
module Metasploit::Cache::Actionable::Ephemeral::Actions
  #
  # Module Methods
  #

  # Builds new `#actions` on `destination`.
  #
  # @param destination [#actions]
  # @param destination_attribute_set [Set<String>] Set of {Metasploit::Cache::Actionable::Action#name}s of
  #   `destination`'s `#actions`.
  # @param source_attribute_set [Set<String>] Set of Metasploit Module instance's action names.
  # @return [#actions] `destination`
  def self.build_added(destination:, destination_attribute_set:, source_attribute_set:)
    added_attributes_set = Metasploit::Cache::Ephemeral::AttributeSet.added(
        destination: destination_attribute_set,
        source: source_attribute_set
    )

    added_attributes_set.each do |name|
      destination.actions.build(name: name)
    end

    destination
  end

  # The set of {Metasploit::Cache::Module::Action} attributes currently persisted.
  #
  # @param destination [#actions] Persistent cache of Metasploit Module instance
  # @return [Set<String>] Set of {Metasploit::Cache::Module::Action#name}s.
  def self.destination_attribute_set(destination)
    if destination.new_record?
      Set.new
    else
      Set.new destination.actions.pluck(:name)
    end
  end

  # Destroys {#actions} on `destination` that are persisted to `destination`, but don't exist in `source`.
  #
  # @param destination [#actions]
  # @param destination_attribute_set [Set<String>] Set of {Metasploit::Cache::Module::Action#name}s of `destination`'s
  #   `#actions`.
  # @param source_attribute_set [Set<String>] Set of Metasploit Module instance's action name.
  # @return [#actions] `destination`
  def self.destroy_removed(destination:, destination_attribute_set:, source_attribute_set:)
    removed_attributes_set = Metasploit::Cache::Ephemeral::AttributeSet.removed(
        destination: destination_attribute_set,
        source: source_attribute_set
    )

    unless destination.new_record? || removed_attributes_set.empty?
      destination.actions.where(
          # AREL cannot visit Set
          name: removed_attributes_set.to_a
      ).destroy_all
    end

    destination
  end

  # The set of action names from the `source` Metasploit Module instance
  #
  # @param source [#actions] Metasploit Module instance that has actions
  # @return [Set<String>] Set of action names.
  def self.source_attribute_set(source)
    source.actions.each_with_object(Set.new) { |source_action, set|
      set.add source_action.name
    }
  end

  # The default action name on the `source` Metasploit Module instance
  #
  # @param source [#default_action]
  # @return [String, nil]
  def self.source_default_action_name(source)
    # The API in metasploit-framework just calls if `default_action` even though it is just a `String` name.
    source.default_action
  end

  # Synchronizes actions from Metasploit Module instance `source` to persisted `#actions` on `destination`.
  #
  # @param destination [ActiveRecord::Base, #actions]
  # @param source [#actions] Metasploit Module instance
  # @return [#actions] `destination`
  def self.synchronize(destination:, source:)
    Metasploit::Cache::Ephemeral.with_connection_transaction(destination_class: destination.class) {
      cached_destination_attribute_set = destination_attribute_set(destination)
      cached_source_attribute_set = source_attribute_set(source)

      reduced = destroy_removed(
          destination: destination,
          destination_attribute_set: cached_destination_attribute_set,
          source_attribute_set: cached_source_attribute_set
      )
      expanded = build_added(
          destination: reduced,
          destination_attribute_set: cached_destination_attribute_set,
          source_attribute_set: cached_source_attribute_set
      )
      update_default_action(
          destination: expanded,
          source: source
      )
    }
  end

  # Updates the `#default_action` on `destination`.
  #
  # @param destination [#default_action]
  # @param source (see #source_attribute_set)
  # @return [#default_action] `destination`
  def self.update_default_action(destination:, source:)
    cached_source_default_action_name = source_default_action_name(source)

    if cached_source_default_action_name
      # reset to `nil` because if source_default_action_name may be invalid and name an undeclared action not in
      # destination.actions.
      destination.default_action = nil

      destination.actions.each do |action|
        if action.name == cached_source_default_action_name
          destination.default_action = action

          break
        end
      end
    end

    destination
  end
end