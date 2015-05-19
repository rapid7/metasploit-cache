class Metasploit::Cache::Architecturable::Architecture < ActiveRecord::Base
  #
  # Associations
  #

  # The architecture supported by the `#architecturable`.
  belongs_to :architecture,
             class_name: 'Metasploit::Cache::Architecture',
             inverse_of: :architecturable_architectures

  #
  # Validations
  #

  validates :architecture,
            presence: true

  Metasploit::Concern.run(self)
end