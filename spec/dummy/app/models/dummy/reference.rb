# Implementation of {Metasploit::Cache::Reference} to allow testing of {Metasploit::Cache::Reference} using an in-memory
# ActiveModel and use of factories.
class Dummy::Reference < Metasploit::Model::Base
  include Metasploit::Cache::Reference

  #
  # Associations
  #

  # @!attribute [rw] authority
  #   The {Metasploit::Cache::Authority authority} that assigned {#designation}.
  #
  #   @return [Metasploit::Cache::Authority, nil]
  attr_accessor :authority

  #
  # Attributes
  #

  # @!attribute [rw] designation
  #   A designation (usually a string of numbers and dashes) assigned by {#authority}.
  #
  #   @return [String, nil]
  attr_accessor :designation

  # @!attribute [rw] url
  #   URL to web page with information about referenced exploit.
  #
  #   @return [String, nil]
  attr_accessor :url
end
