# Loads a {Metasploit::Cache::Encoder::Instance}.
class Metasploit::Cache::Encoder::Instance::Load < Metasploit::Model::Base
  #
  # Attributes
  #

  # The encoder instance being loaded.
  #
  # @return [Metasploit::Cache::Encoder::Instance]
  attr_accessor :encoder_instance

  # Tagged logger to which to log loading errors.
  #
  # @return [ActiveSupport::TaggedLogging]
  attr_accessor :logger

  # `Metasploit<n>` ruby `Class` declared in {Metasploit::Cache::Module::Ancestor#contents}.
  #
  # @return [Class, #ephemeral_cache_by_source] Must have `ephemeral_cache_by_source[:class]`
  attr_accessor :encoder_metasploit_module_class
  
  # Exception raised when `new` is called on {#encoder_metasploit_module_class}.
  #
  # @return [nil] if {#encoder_metasploit_module_instance} has not run yet.
  # @return [nil] if no exception was raised.
  # @return [Exception] if exception was raised.
  attr_reader :encoder_metasploit_module_class_new_exception

  #
  #
  # Validations
  #
  #

  #
  # Method Validations
  #

  validate :encoder_metasploit_module_class_new_valid,
           unless: :loading_context?

  #
  # Attribute Validations
  #

  validates :encoder_instance,
            presence: true
  validates :encoder_metasploit_module_instance,
            presence: {
                unless: :loading_context?
            }
  validates :encoder_metasploit_module_class,
            presence: true
  validates :logger,
            presence: true

  #
  # Instance Methods
  #

  # Instance of {#encoder_metasploit_module_class} loaded into the cache.
  #
  # @return [Metasploit::Cache::Cacheable] if new instance of {#encoder_metasploit_module_class} could be loaded into
  #   the cache.
  # @return [nil] if new instance of {#encoder_metasploit_module_class} could not be created.
  # @return [nil] if new instance of {#encoder_metasploit_module_class} could not be persisted to cache.
  def encoder_metasploit_module_instance
    unless instance_variable_defined? :@encoder_metasploit_module_instance
      if valid?(:loading)
        @encoder_metasploit_module_instance = nil

        instance = encoder_metasploit_module_class_new

        if instance
          instance.extend Metasploit::Cache::Cacheable
          ephemeral_cache = Metasploit::Cache::Encoder::Instance::Ephemeral.new(
              encoder_metasploit_module_instance: instance,
              logger: logger
          )
          instance.ephemeral_cache_by_source[:instance] = ephemeral_cache

          if ephemeral_cache.valid?
            ephemeral_cache.persist(to: encoder_instance)

            if encoder_instance.persisted?
              @encoder_metasploit_module_instance = instance
            end
          end
        end
      end
    end

    @encoder_metasploit_module_instance
  end

  private

  # Attempts to instantiate {#encoder_metasploit_module_class}.
  #
  # @return [Object] instance of {#encoder_metasploit_module_class}
  # @return [nil] if not valid for loading
  # @return [nil] if exception is raise when `encoder_metasploit_module.new` is called.
  #   Exception is saved to `encoder_metasploit_module_class_new_exception`.
  def encoder_metasploit_module_class_new
    begin
      encoder_metasploit_module_class.new
    rescue Interrupt
      # handle Interrupt as pass-through unlike other Exceptions so users can bail with Ctrl+C
      raise
    rescue Exception => exception
      @encoder_metasploit_module_class_new_exception = exception

      nil
    end
  end
  
  # Copies error in {#encoder_metasploit_module_class_new_exception} to validation error on
  # `:encoder_metasploit_module_class`.
  #
  # @return [void]
  def encoder_metasploit_module_class_new_valid
    if encoder_metasploit_module_class_new_exception
      errors.add(
                :encoder_metasploit_module_class_new,
                "#{encoder_metasploit_module_class_new_exception.class} " \
                "#{encoder_metasploit_module_class_new_exception}:\n" \
                "#{encoder_metasploit_module_class_new_exception.backtrace.join("\n")}"
      )
    end
  end

  # Whether the current `#validation_context` is `:loading`.
  #
  # @return [true] if `#validation_context` is `:loading`.
  # @return [false] otherwise
  def loading_context?
    validation_context == :loading
  end
end