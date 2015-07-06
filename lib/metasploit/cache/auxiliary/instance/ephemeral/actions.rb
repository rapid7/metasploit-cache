# Synchronizes the persistent cache of {Metasploit::Cache::Auxiliary::Instance#actions} with the in-memory actions
# on the {Metasploit::Cache::Auxiliary::Instance::Ephemeral#auxiliary_metasploit_module_instance}.
module Metasploit::Cache::Auxiliary::Instance::Ephemeral::Actions
  #
  # Module Methods
  #

  # The set of {Metasploit::Cache::Module::Action} attributes for added
  # {Metasploit::Cache::Auxiliary::Instance#actions}.
  #
  # @return [Hash{Symbol => Object}]
  def self.added_attributes_set(destination_attribute_set:, source_attribute_set:)
    source_attribute_set - destination_attribute_set
  end

  # Builds new {Metasploit::Cache::Auxiliary::Instance#actions} on `destination`.
  #
  # @param destination [Metasploit::Cache::Auxiliary::Instance]
  # @param source (see #source_attribute_set)
  # @return [Metasploit::Cache;:Auxiliary::Instance] `destination`
  def self.build_added(destination:, source:)
    destination_attribute_set = self.destination_attribute_set(destination)
    source_attribute_set = self.source_attribute_set(source)
    added_attributes_set = self.added_attributes_set(
        destination_attribute_set: destination_attribute_set,
        source_attribute_set: source_attribute_set
    )

    added_attributes_set.each do |name|
      destination.actions.build(name: name)
    end

    destination
  end

  # The set of {Metasploit::Cache::Module::Action} attributes currently persisted.
  #
  # @param destination [Metasploit::Cache::Auxiliary::Instance] Persistant cache of auxiliary Metasploit Module instance
  # @return [Set<String>] Set of {Metasploit::Cache::Module::Action#name}s.
  def self.destination_attribute_set(destination)
    if destination.new_record?
      Set.new
    else
      Set.new destination.actions.pluck(:name)
    end
  end

  # Destroys {Metasploit::Cache::Auxiliary::Instance#actions} that are persisted to `destination`, but don't exist in
  # `source`.
  #
  # @param destination [Metasploit::Cache::Auxiliary::Instance]
  # @param source (see #source_attribute_set)
  # @return [Metasploit::Cache;:Auxiliary::Instance] `destination`
  def self.destroy_removed(destination:, source:)
    destination_attribute_set = self.destination_attribute_set(destination)
    source_attribute_set = self.source_attribute_set(source)
    removed_attributes_set = self.removed_attributes_set(
        destination_attribute_set: destination_attribute_set,
        source_attribute_set: source_attribute_set
    )

    unless destination.new_record? || removed_attributes_set.empty?
      destination.actions.where(
          # AREL cannot visit Set
          name: removed_attributes_set.to_a
      ).destroy_all
    end

    destination
  end

  # The set of {Metasploit::Cache::Module::Action} attributes for destroyed
  # {Metasploit::Cache::Auxiliary::Instance#actions}.
  #
  # @param destination_attribute_set [Set<String>] Set of {Metasploit::Cache::Module::Action#name}s.
  # @param source_attribute_set [Set<String>] Set of action names from auxiliary Metasploit Module instance
  # @return [Set<String>] Set of {Metasploit::Cache::Module::Action#name}s.
  def self.removed_attributes_set(destination_attribute_set:, source_attribute_set:)
    destination_attribute_set - source_attribute_set
  end

  # The set of action names from the `source` auxiliary Metasploit Module instance
  #
  # @param source [#actions] auxiliary Metasploit Module instance that has actions
  # @return [Set<String>] Set of action names.
  def self.source_attribute_set(source)
    source.actions.each_with_object(Set.new) { |source_action, set|
      set.add source_action.name
    }
  end

  # The default action name on the `source` auxiliary Metasploit Module instance
  #
  # @param source [#default_action]
  # @return [String, nil]
  def self.source_default_action_name(source)
    # The API in metasploit-framework just calls if `default_action` even though it is just a `String` name.
    source.default_action
  end


  # Synchronizes actions from auxiliary Metasploit Module instance `source` to persisted
  # {Metasploit::Cache::Auxiliary::Instance#actions} on `destination`.
  #
  # @param destination [Metasploit::Cache::Auxiliary::Instance]
  # @param source [#actions] auxiliary Metasploit Module instance
  # @return [Metasploit::Cache::Auxiliary::Instance] `destination`
  def self.synchronize(destination:, source:)
    transaction(destination: destination) {
      [:destroy_removed, :build_added, :update_default_action].reduce(destination) { |block_destination, transform|
        send(transform, destination: block_destination, source: source)
      }
    }
  end

  # Runs transaction on destination using temporary from the connection pool that is returned at end of `block`.
  #
  # @param destination [Metasploit::Cache::Auxiliary::Instance]
  # @yield Block run in database transaction
  # @yieldreturn [Object] value to return
  # @return [Object] value returned from `block`.
  def self.transaction(destination:, &block)
    destination.class.connection_pool.with_connection do
      destination.transaction(&block)
    end
  end

  # Updates the {Metasploit::Cache::Auxiliary::Instance#default_action}.
  #
  # @param destination [Metasploit::Cache::Auxiliary::Instance]
  # @param source (see #source_attribute_set)
  # @return [Metasploit::Cache;:Auxiliary::Instance] `destination`
  def self.update_default_action(destination:, source:)
    source_default_action_name = self.source_default_action_name(source)

    if source_default_action_name
      destination.actions.each do |action|
        if action.name == source_default_action_name
          destination.default_action = action

          break
        end
      end
    end

    destination
  end
end