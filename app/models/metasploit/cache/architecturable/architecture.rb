class Metasploit::Cache::Architecturable::Architecture < ActiveRecord::Base
  #
  # Associations
  #

  # The thing that supports {#architecture}.
  belongs_to :architecturable,
             inverse_of: :architecturable_architectures,
             polymorphic: true

  # The architecture supported by the {#architecturable}.
  belongs_to :architecture,
             class_name: 'Metasploit::Cache::Architecture',
             inverse_of: :architecturable_architectures

  #
  # Validations
  #

  validates :architecturable,
            presence: true
  validates :architecture,
            presence: true
  validates :architecture_id,
            uniqueness: {
                scope: [
                    :architecturable_type,
                    :architecturable_id
                ]
            }

  Metasploit::Concern.run(self)
end