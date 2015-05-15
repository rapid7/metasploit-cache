# Represents licenses like BSD, MIT, etc used to provide license information for {Metasploit::Cache::Module::Instance modules}
class Metasploit::Cache::License < ActiveRecord::Base
  extend ActiveSupport::Autoload

  #
  # Attributes
  #

  # @!attribute abbreviation
  #   Abbreviated license name
  #
  #   @return [String]

  # @!attribute summary
  #   Summary of the license text
  #
  #   @return [String]

  # @!attribute url
  #   URL of the full license text
  #
  #   @return [String]


  #
  # Validations
  #

  validates :abbreviation,
            uniqueness: true,
            presence: true

  validates :summary,
            uniqueness: true,
            presence: true

  validates :url,
            uniqueness: true,
            presence: true


  Metasploit::Concern.run(self)
end

