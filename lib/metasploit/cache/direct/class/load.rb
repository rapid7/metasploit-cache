# Loads a {Metasploit::Cache::Direct::Class}.
class Metasploit::Cache::Direct::Class::Load < Metasploit::Model::Base
  #
  # Attributes
  #

  # The direct class being loaded.
  #
  # @return [Metasploit::Cache::Direct::Class]
  attr_accessor :direct_class

  # Tagged logger to which to load loading errors.
  #
  # @return [ActiveSupport::TaggedLogging]
  attr_accessor :logger

  # `Metasploit<n>` ruby `Module` declared in {Metasploit::Cache::Module::Ancestor#contents}.
  #
  # @return [Module<Metasploit::Cache::Cacheable>] Must be have a `persister_by_source[:ancestor]`.
  attr_accessor :metasploit_module

  #
  #
  # Validations
  #
  #

  #
  # Method Validations
  #

  validate :direct_class_valid,
           unless: :loading_context?
  validate :metasploit_class_usable,
           unless: :loading_context?

  #
  # Attribute Validations
  #

  validates :logger,
            presence: true
  validates :direct_class,
            presence: true
  validates :metasploit_class,
            presence: {
                unless: :loading_context?
            }
  validates :metasploit_module,
            presence: true


  #
  # Instance Methods
  #

  # `Metasploit<n>` ruby `Class` declared in {Metasploit::Cache::Module::Ancestor#contents}.
  #
  # @return [Class]
  def metasploit_class
    unless instance_variable_defined? :@metasploit_class
      if valid?(:loading)
        @metasploit_class = nil

        persister = Metasploit::Cache::Direct::Class::Persister.new(
            ephemeral: metasploit_module,
            logger: logger,
            persistent_class: direct_class.class
        )
        metasploit_module.persister_by_source[:class] = persister

        if persister.valid?
          persister.persist(to: direct_class)

          if direct_class.persisted?
            # The load only succeeded if the metadata was persisted, so @metasploit_class is `nil` otherwise.
            @metasploit_class = metasploit_module
          end
        end
      end
    end

    @metasploit_class
  end

  private

  # Validates that {#direct_class} is valid, but only if {#direct_class} is not `nil`.
  #
  # @return [void]
  def direct_class_valid
    # allow the presence validation to handle it being nil
    if direct_class && direct_class.invalid?
      errors.add(:direct_class, :invalid)
    end
  end

  # Whether the current `#validation_context` is `:loading`.
  #
  # @return [true] if `#validation_context` is `:loading`.
  # @return [false] otherwise
  def loading_context?
    validation_context == :loading
  end

  # Validates that {#metasploit_class} is usable on this local platform, but only if {#metasploit_class} is not `nil`.
  #
  # @return [void]
  def metasploit_class_usable
    if metasploit_class && !metasploit_class.is_usable
      errors.add(:metasploit_class, :unusable)
    end
  end
end