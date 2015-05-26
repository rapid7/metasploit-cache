# A contribution an `#author` made using a given `#email_address` to a polymorphic `#contributable`.
class Metasploit::Cache::Contribution < ActiveRecord::Base
  #
  # Associations
  #

  # Name of the contributor.
  belongs_to :author,
             class_name: 'Metasploit::Cache::Author',
             inverse_of: :contributions

  Metasploit::Concern.run(self)
end