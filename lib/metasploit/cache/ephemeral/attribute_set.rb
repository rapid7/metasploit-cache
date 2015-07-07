# Operations on attribute set for converting from in-memory attributes to persisted cached attributes
module Metasploit::Cache::Ephemeral::AttributeSet
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

  # The set of attributes for records to destroy on destination.
  #
  # @param destination [Set] set of attributes from destination persisted cache
  # @param source [Set] set of attributes from in-memory Metasploit Module instance
  # @return [Set]
  def self.removed(destination:, source:)
    destination - source
  end
end