# Implementation of {Metasploit::Cache::Author} to allow testing of {Metasploit::Cache::Author} using an in-memory
# ActiveModel and use of factories.
class Dummy::Author < Metasploit::Model::Base
  include Metasploit::Cache::Author

  #
  # Attributes
  #

  # @!attribute [rw] name
  #   Full name (First + Last name) or handle of author.
  #
  #   @return [String]
  attr_accessor :name
end