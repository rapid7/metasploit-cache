# Loads a {Metasploit::Cache::Payload::Direct::Class}.
class Metasploit::Cache::Payload::Direct::Class::Load < Metasploit::Model::Base
  #
  # CONSTANTS
  #

  # The base namespace name under which {metasploit_class_names} are generated.
  METASPLOIT_CLASS_NAMES = ['Msf', 'Payloads']

  #
  # Attributes
  #

  # Tagged logger to which to load loading errors.
  #
  # @return [ActiveSupport::TaggedLogging]
  attr_accessor :logger

  # `Metasploit<n>` ruby `Module` declared in {Metasploit::Cache::Module::Ancestor#contents}.
  #
  # @return [Module<Metasploit::Cache::Cacheable>] Must be have a `ephemeral_cache_by_source[:ancestor]`.
  attr_accessor :metasploit_module

  # The direct payload class being loaded.
  #
  # @return [Metasploit::Cache::Payload::Direct::Class]
  attr_accessor :payload_direct_class

  # The superclass to subclass and include {#metasploit_module} into.
  #
  # @return [Class, #rank, #is_usable]
  attr_accessor :payload_superclass

  #
  #
  # Validations
  #
  #

  #
  # Method Validations
  #

  validate :payload_direct_class_valid,
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
  validates :payload_direct_class,
            presence: true
  validates :payload_superclass,
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

        # There is no specialized Metasploit::Cache::Payload::Direct::Class::Ephemeral because metadata is the same
        # for Metasploit::Cache::Payload::Direct::Class once the metasploit_class is mixed.
        ephemeral_cache = Metasploit::Cache::Direct::Class::Ephemeral.new(
            direct_class_class: payload_direct_class.class,
            logger: logger,
            metasploit_class: metasploit_class
        )

        metasploit_class.ephemeral_cache_by_source[:class] = ephemeral_cache

        if ephemeral_cache.valid?
          ephemeral_cache.persist_direct_class(to: payload_direct_class)

          if payload_direct_class.persisted?
            # Name class so that it can be looked up by name to prevent unnecessary reloading.
            self.class.name_metasploit_class!(
                metasploit_class: metasploit_class,
                payload_direct_class: payload_direct_class
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
  # @param payload_direct_class [Metasploit::Cache::Payload::Direct::Class] Whose names to calculate
  # @return [Array<String>]
  def self.metasploit_class_names(payload_direct_class)
    METASPLOIT_CLASS_NAMES + ["RealPathSha1HexDigest#{payload_direct_class.ancestor.real_path_sha1_hex_digest}"]
  end

  # Sets name of anonymous ruby `Class`.
  #
  # @param metasploit_class [Class] anonymous ruby `Class` loaded by {#metasploit_class}.
  # @param payload_direct_class [Metasploit::Cache::Payload::Direct::Class] Used to calculate name.
  # @return [nil] There was no pre-existing constant with the same {metasploit_class_names}.
  # @return [Object] The pre-existing constant with the same {metasploit_class_names} that was replaced.
  def self.name_metasploit_class!(metasploit_class:, payload_direct_class:)
    names = metasploit_class_names(payload_direct_class)
    parent_names = names[0 ... -1]
    relative_name = names[-1]

    parent = Metasploit::Cache::Constant.current(parent_names)

    if parent.nil?
      parent = Metasploit::Cache::Constant.inject(parent_names) { |current_parent, current_relative_name|
        current_parent.const_set(current_relative_name, Module.new)
      }
    end

    Metasploit::Cache::Constant.swap_on_parent(
        constant: metasploit_class,
        parent: parent,
        relative_name: relative_name
    )
  end

  private

  # Validates that {#payload_direct_class} is valid, but only if {#payload_direct_class} is not `nil`.
  #
  # @return [void]
  def payload_direct_class_valid
    # allow the presence validation to handle it being nil
    if payload_direct_class && payload_direct_class.invalid?
      errors.add(:payload_direct_class, :invalid)
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