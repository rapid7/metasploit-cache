# The reliability of the module and likelyhood that the module won't knock over the service or host being exploited.
# Bigger {#number values} are better.
class Metasploit::Cache::Module::Rank < ActiveRecord::Base
  extend ActiveSupport::Autoload

  include Metasploit::Model::Search
  include Metasploit::Model::Translation

  autoload :Seed

  #
  # CONSTANTS
  #

  # Regular expression to ensure that {#name} is a word starting with a capital letter
  NAME_REGEXP = /\A[A-Z][a-z]+\Z/

  # Converts {#name} to {#number}.  Used for seeding.  Seeds exist so that reports can use module_ranks to get the
  # name of a rank without having to duplicate this constant.
  NUMBER_BY_NAME = {
      'Manual' => 0,
      'Low' => 100,
      'Average' => 200,
      'Normal' => 300,
      'Good' => 400,
      'Great' => 500,
      'Excellent' => 600
  }
  # Converts {#number} to {#name}.  Used to convert *Ranking constants used in `Msf::Modules` back to Strings.
  NAME_BY_NUMBER = NUMBER_BY_NAME.invert

  #
  # Associations
  #

  # {Metasploit::Cache::Auxiliary::Class Auxiliary classes} assigned this rank.
  has_many :auxiliary_classes,
           class_name: 'Metasploit::Cache::Auxiliary::Class',
           dependent: :destroy,
           inverse_of: :rank
  # {Metasploit::Cache::Module::Class Module classes} assigned this rank.
  has_many :module_classes, class_name: 'Metasploit::Cache::Module::Class', dependent: :destroy, inverse_of: :rank

  #
  # Attributes
  #

  # @!attribute name
  #   The name of the rank.
  #
  #   @return [String]

  # @!attribute number
  #   The numerical value of the rank.  Higher numbers are better.
  #
  #   @return [Integer]

  #
  # Mass Assignment Security
  #

  attr_accessible :name
  attr_accessible :number

  #
  # Search Attributes
  #

  search_attribute :name, type: :string
  search_attribute :number, type: :integer

  #
  # Validations
  #

  validates :name,
            # To ensure NUMBER_BY_NAME and seeds stay in sync.
            inclusion: {
                in: NUMBER_BY_NAME.keys
            },
            # To ensure new seeds follow pattern.
            format: {
                with: NAME_REGEXP
            },
            uniqueness: true
  validates :number,
            # to ensure NUMBER_BY_NAME and seeds stay in sync.
            inclusion: {
                in: NUMBER_BY_NAME.values
            },
            # To ensure new seeds follow pattern.
            numericality: {
                only_integer: true
            },
            uniqueness: true

  #
  # Instance Methods
  #

  # @!method name=(name)
  #   Sets {#name}.
  #
  #   @param name [String] the name of the rank.
  #   @return [void]

  # @!method number=(number)
  #   Sets {#number}.
  #
  #   @param number [Integer] the numerical value of teh rank.  Higher numbers are better.
  #   @return [void]

  Metasploit::Concern.run(self)
end