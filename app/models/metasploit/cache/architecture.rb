# The architecture of a host's cpu or that is targeted by the shellcode for a
# {Metasploit::Cache::Module::Instance module}.
class Metasploit::Cache::Architecture < ActiveRecord::Base
  extend ActiveSupport::Autoload

  include Metasploit::Model::Translation
  include Metasploit::Model::Search

  autoload :Seed

  #
  # CONSTANTS
  #

  # Valid values for {#abbreviation}
  ABBREVIATIONS = [
      'armbe',
      'armle',
      'cbea',
      'cbea64',
      'cmd',
      'dalvik',
      'firefox',
      'java',
      'mipsbe',
      'mipsle',
      'nodejs',
      'php',
      'ppc',
      'ppc64',
      'python',
      'ruby',
      'sparc',
      'tty',
      'x86',
      'x86_64'
  ]
  # Valid values for {#bits}.
  BITS = [
      32,
      64
  ]
  # Valid values for {#endianness}.
  ENDIANNESSES = [
      'big',
      'little'
  ]
  # Valid values for {#family}.
  FAMILIES = [
      'arm',
      'cbea',
      'javascript',
      'mips',
      'ppc',
      'sparc',
      'x86'
  ]

  #
  #
  # Associations
  #
  #

  # Join model between this {Metasploit::Cache::Architecture} and Metasploit Module instances or
  # {Metasploit::Cache::Exploit::Target exploit Metasploit Module targets}
  has_many :architecturable_architectures,
           as: :architecturable,
           class_name: 'Metasploit::Cache::Architecturable::Architecture',
           dependent: :destroy,
           inverse_of: :architecture

  #
  # Attributes
  #

  # @!attribute abbreviation
  #   Abbreviation used for the architecture.  Will match ARCH constants in metasploit-framework.
  #
  #   @return [String]

  # @!attribute bits
  #   Number of bits supported by this architecture.
  #
  #   @return [32] if 32-bit
  #   @return [64] if 64-bit
  #   @return [nil] if bits aren't applicable, such as for non-CPU architectures like ruby, etc.

  # @!attribute endianness
  #   The endianness of the architecture.
  #
  #   @return ['big'] if big endian
  #   @return ['little'] if little endian
  #   @return [nil] if endianness is not applicable, such as for software architectures like tty.

  # @!attribute family
  #   The CPU architecture family.
  #
  #   @return [String] if a CPU architecture.
  #   @return [nil] if not a CPU architecture.

  # @!attribute summary
  #   Sentence length summary of architecture.  Usually an expansion of the abbreviation or initialism in the
  #   {#abbreviation} and the {#bits} and {#endianness} in prose.
  #
  #   @return [String]

  #
  # Search Attributes
  #

  search_attribute :abbreviation,
                   type: {
                       set: :string
                   }
  search_attribute :bits,
                   type: {
                       set: :integer
                   }
  search_attribute :endianness,
                   type: {
                       set: :string
                   }
  search_attribute :family,
                   type: {
                       set: :string
                   }

  #
  # Validations
  #

  validates :abbreviation,
            inclusion: {
                in: ABBREVIATIONS
            },
            uniqueness: true
  validates :bits,
            inclusion: {
                allow_nil: true,
                in: BITS
            }
  validates :endianness,
            inclusion: {
                allow_nil: true,
                in: ENDIANNESSES
            }
  validates :family,
            inclusion: {
                allow_nil: true,
                in: FAMILIES
            }
  validates :summary,
            presence: true,
            uniqueness: true

  #
  # Class Methods
  #

  # Set of valid values to search for `attribute`.  Does not include `nil` as search syntax cannot differentiate
  # '' and nil when parsing.
  #
  # @param attribute [Symbol] attribute name.
  # @return [Set]
  def self.set(attribute)
    self::Seed::ATTRIBUTES.each_with_object(Set.new) { |attributes, set|
      value = attributes.fetch(attribute)

      unless value.nil?
        set.add value
      end
    }
  end

  # @!method self.abbreviation_set
  #   Set of valid {Metasploit::Cache::Architecture#abbreviation} for search.
  #
  #   @return [Set<String>]
  #
  # @!method self.bits_set
  #   Set of valid {Metasploit::Cache::Architecture#bits} for search.
  #
  #   @return [Set<Integer>]
  #
  # @!method self.endianness_set
  #   Set of valid {Metasploit::Cache::Architecture#endianness} for search.
  #
  #   @return [Set<String>]
  #
  # @!method self.family_set
  #   Set of valid {Metasploit::Cache::Architecture#family} for search.
  #
  #   @return [Set<String>]
  [:abbreviation, :bits, :endianness, :family].each do |attribute|
    # calculate external to method so it is only calculated once
    attribute_set = self.set(attribute)

    define_singleton_method("#{attribute}_set") do
      attribute_set
    end
  end

  Metasploit::Concern.run(self)
end