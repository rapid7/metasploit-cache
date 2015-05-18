# Join model for associating Metasploit::Cache::*::Instance objects with {Metasploit::Cache::License} objects.
# Implements a polymorphic association that the other models use for implementing `#licenses`.
class Metasploit::Cache::Licensable::License < ActiveRecord::Base

  #
  # Attributes
  #


  #
  # Associations
  #

  # Allows many classes to have a {Metasploit::Cache::License} object
  belongs_to :licensable,
             polymorphic: true


  #
  # Validations
  #

  Metasploit::Concern.run(self)
end
