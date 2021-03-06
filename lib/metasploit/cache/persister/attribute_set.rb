# Operations on attribute set for converting from in-memory attributes to persisted cached attributes
module Metasploit::Cache::Persister::AttributeSet
  #
  # Module Methods
  #

  # The set of attributes for record to added to destination
  #
  # @param destination [Set] set of attributes from destination persisted cache
  # @param source [Set] set of attributes from in-memory Metasploit Module instance
  # @return [Set]
  def self.added(destination:, source:)
    source - destination
  end

  # Maps values of `attribute` in `value_set` to records in `scope`.
  #
  # @param attribute [Symbol] name of attribute with `value_set` values.
  # @param scope [#isolation_level, #transaction, #where] Scope for looking up persisted record that have
  #   `attribute_set` values on `attribute`.
  # @param value_set [Enumerable<Object>, #to_a] Set of values of `attribute` on `active_record_subclass`
  # @return [Hash{Object => ActiveRecord::Base}] Maps values of `attribute` to instances of `active_record_subclass`.
  def self.existing_by_attribute_value(attribute:, scope:, value_set:)
    if value_set.empty?
      {}
    else
      scope.isolation_level(:repeatable_read) {
        scope.transaction {
          scope.where(
              # AREL cannot visit Set
              attribute => value_set.to_a
          ).each_with_object({}) { |record, record_by_attribute_value|
            record_by_attribute_value[record.public_send(attribute)] = record
          }
        }
      }
    end
  end

  # The set of attributes for records to destroy on destination.
  #
  # @param destination [Set] set of attributes from destination persisted cache
  # @param source [Set] set of attributes from in-memory Metasploit Module instance
  # @return [Set]
  def self.removed(destination:, source:)
    destination - source
  end

  # The set of attributes for records to either maintained or updated on destination.
  #
  # @param destination [Set] set of attributes from destination persisted cache
  # @param source [Set] set of attributes from in-memory Metasploit Module instance
  # @return [Set]
  def self.retained(destination:, source:)
    destination & source
  end
end