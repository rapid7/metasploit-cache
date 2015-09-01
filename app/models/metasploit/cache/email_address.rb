# Email address for used by an {Metasploit::Cache::Author} for {Metasploit::Cache::Module::Author credit} on a given {Metasploit::Cache::Module::Instance module}.
class Metasploit::Cache::EmailAddress < ActiveRecord::Base
  extend ActiveSupport::Autoload

  include Metasploit::Cache::Batch::Descendant
  include Metasploit::Cache::Derivation
  include Metasploit::Model::Search
  include Metasploit::Model::Translation

  autoload :Ephemeral

  #
  # Associations
  #

  # Credits where authors used this email address for their contributions.
  has_many :contributions,
           as: :email_address,
           class_name: 'Metasploit::Cache::Contribution',
           dependent: :destroy,
           inverse_of: :email_address

  #
  # through: :contributions
  #

  # Authors that used this email address.
  has_many :authors,
           class_name: 'Metasploit::Cache::Author',
           through: :contributions

  #
  # Attributes
  #

  # @!attribute domain
  #   The domain part of the email address after the `'@'`.
  #
  #   @return [String]

  # @!attribute full
  #   The full email address.
  #
  #   @return [String] <{#local}>@<{#domain}>

  # @!attribute local
  #   The local part of the email address before the `'@'`.
  #
  #   @return [String]

  #
  # Derivations
  #

  derives :domain, validate: true
  derives :full, validate: true
  derives :local, validate: true

  #
  # Search Attributes
  #

  search_attribute :domain, type: :string
  search_attribute :full, type: :string
  search_attribute :local, type: :string

  #
  # Validations
  #

  validates :domain,
            presence: true
  validates :full,
            uniqueness: {
                unless: :batched?
            }
  validates :local,
            presence: true,
            uniqueness: {
                scope: :domain,
                unless: :batched?
            }

  #
  # Instance Methods
  #

  # Derives {#domain} from {#full}
  #
  # @return [String] if {#full} is present
  # @return [nil] if {#full} is not present
  def derived_domain
    domain = nil

    if full.present?
      _local, domain = full.split('@', 2)
    end

    domain
  end

  # Derives {#full} from {#domain} and {#local}
  #
  # @return [String]
  def derived_full
    if domain.present? && local.present?
      "#{local}@#{domain}"
    end
  end

  # Derives {#local} from {#full}.
  #
  # @return [String] if {#full} is present
  # @return [nil] if {#full} is not present
  def derived_local
    local = nil

    if full.present?
      local, _domain = full.split('@', 2)
    end

    local
  end

  Metasploit::Concern.run(self)
end