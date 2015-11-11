# Loads a {Metasploit::Cache::Payload::Unhandled::Class}.
class Metasploit::Cache::Payload::Unhandled::Class::Load < Metasploit::Model::Base
  #
  # CONSTANTS
  #

  # The base namespace name under which {metasploit_class_names} are generated.
  METASPLOIT_CLASS_NAMES = ['Msf', 'Payloads', 'Unhandled']

  #
  # Attributes
  #

  # Tagged logger to which to load loading errors.
  #
  # @return [ActiveSupport::TaggedLogging]
  attr_accessor :logger

  # `Metasploit<n>` ruby `Module` declared in {Metasploit::Cache::Module::Ancestor#contents}.
  #
  # @return [Module<Metasploit::Cache::Cacheable>] Must be have a `persister_by_source[:ancestor]`.
  attr_accessor :metasploit_module

  # The superclass to subclass and include {#metasploit_module} into.
  #
  # @return [Class, #rank, #is_usable]
  attr_accessor :payload_superclass

  # The payload class with a handler being loaded.
  #
  # @return [Metasploit::Cache::Payload::Unhandled::Class]
  attr_accessor :payload_unhandled_class

  #
  #
  # Validations
  #
  #

  #
  # Method Validations
  #

  validate :payload_unhandled_class_valid,
           unless: :loading_context?
  validate :metasploit_class_usable,
           unless: :loading_context?

  #
  # Attribute Validations
  #

  validates :logger,
            presence: true
  validates :metasploit_class,
            presence: {
                unless: :loading_context?
            }
  validates :metasploit_module,
            presence: true
  validates :payload_superclass,
            presence: true
  validates :payload_unhandled_class,
            presence: true

  #
  # Instance Methods
  #

  # Subclass of {#payload_superclass} with {#metasploit_module} mixed in.
  #
  # @return [Class]
  def metasploit_class
    unless instance_variable_defined? :@metasploit_class
      if valid?(:loading)
        @metasploit_class = nil

        metasploit_class = Class.new(payload_superclass)
        metasploit_class.extend Metasploit::Cache::Cacheable
        metasploit_class.include metasploit_module

        persister = Metasploit::Cache::Payload::Unhandled::Class::Persister.new(
            ephemeral: metasploit_class,
            logger: logger,
            persistent_class: payload_unhandled_class.class
        )

        metasploit_class.persister_by_source[:class] = persister

        if persister.valid?
          persister.persist(to: payload_unhandled_class)

          if payload_unhandled_class.persisted?
            # Name class so that it can be looked up by name to prevent unnecessary reloading.
            Metasploit::Cache::Constant.name(
                constant: metasploit_class,
                names: self.class.metasploit_class_names(payload_unhandled_class)
            )
            # The load only succeeded if the metadata was persisted, so @metasploit_class is `nil` otherwise.
            @metasploit_class = metasploit_class
          end
        end
      end
    end

    @metasploit_class
  end

  # Returns names for the {#metasploit_class} and its namespaces.
  #
  # @param payload_unhandled_class [Metasploit::Cache::Payload::Unhandled::Class] Whose names to calculate
  # @return [Array<String>]
  def self.metasploit_class_names(payload_unhandled_class)
    METASPLOIT_CLASS_NAMES + ["RealPathSha1HexDigest#{payload_unhandled_class.ancestor.real_path_sha1_hex_digest}"]
  end

  private

  # Validates that {#payload_unhandled_class} is valid, but only if {#payload_unhandled_class} is not `nil`.
  #
  # @return [void]
  def payload_unhandled_class_valid
    # allow the presence validation to handle it being nil
    if payload_unhandled_class && payload_unhandled_class.invalid?
      errors.add(:payload_unhandled_class, :invalid)
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