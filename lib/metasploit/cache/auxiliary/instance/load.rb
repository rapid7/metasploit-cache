# Loads a {Metasploit::Cache::Auxiliary::Instance}.
class Metasploit::Cache::Auxiliary::Instance::Load < Metasploit::Model::Base
  #
  # Attributes
  #

  # The auxiliary instance being loaded.
  #
  # @return [Metasploit::Cache::Auxiliary::Instance]
  attr_accessor :auxiliary_instance

  # Tagged logger to which to log loading errors.
  #
  # @return [ActiveSupport::TaggedLogging]
  attr_accessor :logger

  # `Metasploit<n>` ruby `Class` declared in {Metasploit::Cache::Module::Ancestor#contents}.
  #
  # @return [Class, #ephemeral_cache_by_source] Must have `ephemeral_cache_by_source[:class]`
  attr_accessor :auxiliary_metasploit_module_class
  
  # Exception raised when `new` is called on {#auxiliary_metasploit_module_class}.
  #
  # @return [nil] if {#auxiliary_metasploit_module_instance} has not run yet.
  # @return [nil] if no exception was raised.
  # @return [Exception] if exception was raised.
  attr_reader :auxiliary_metasploit_module_class_new_exception

  #
  #
  # Validations
  #
  #

  #
  # Method Validations
  #

  validate :auxiliary_metasploit_module_class_new_valid,
           unless: :loading_context?

  #
  # Attribute Validations
  #

  validates :auxiliary_instance,
            presence: true
  validates :auxiliary_metasploit_module_instance,
            presence: {
                unless: :loading_context?
            }
  validates :auxiliary_metasploit_module_class,
            presence: true
  validates :logger,
            presence: true

  #
  # Instance Methods
  #

  # Instance of {#auxiliary_metasploit_module_class} loaded into the cache.
  #
  # @return [Metasploit::Cache::Cacheable] if new instance of {#auxiliary_metasploit_module_class} could be loaded into
  #   the cache.
  # @return [nil] if new instance of {#auxiliary_metasploit_module_class} could not be created.
  # @return [nil] if new instance of {#auxiliary_metasploit_module_class} could not be persisted to cache.
  def auxiliary_metasploit_module_instance
    unless instance_variable_defined? :@auxiliary_metasploit_module_instance
      if valid?(:loading)
        @auxiliary_metasploit_module_instance = nil

        instance = auxiliary_metasploit_module_class_new

        if instance
          instance.extend Metasploit::Cache::Cacheable
          ephemeral_cache = Metasploit::Cache::Auxiliary::Instance::Ephemeral.new(
              auxiliary_metasploit_module_instance: instance,
              logger: logger
          )
          instance.ephemeral_cache_by_source[:instance] = ephemeral_cache

          if ephemeral_cache.valid?
            ephemeral_cache.persist(to: auxiliary_instance)

            if auxiliary_instance.persisted?
              @auxiliary_metasploit_module_instance = instance
            end
          end
        end
      end
    end

    @auxiliary_metasploit_module_instance
  end

  private

  # Attempts to instantiate {#auxiliary_metasploit_module_class}.
  #
  # @return [Object] instance of {#auxiliary_metasploit_module_class}
  # @return [nil] if not valid for loading
  # @return [nil] if exception is raise when `auxiliary_metasploit_module.new` is called.
  #   Exception is saved to `auxiliary_metasploit_module_class_new_exception`.
  def auxiliary_metasploit_module_class_new
    begin
      auxiliary_metasploit_module_class.new
    rescue Interrupt
      # handle Interrupt as pass-through unlike other Exceptions so users can bail with Ctrl+C
      raise
    rescue Exception => exception
      @auxiliary_metasploit_module_class_new_exception = exception

      nil
    end
  end
  
  # Copies error in {#auxiliary_metasploit_module_class_new_exception} to validation error on
  # `:auxiliary_metasploit_module_class`.
  #
  # @return [void]
  def auxiliary_metasploit_module_class_new_valid
    if auxiliary_metasploit_module_class_new_exception
      errors.add(
                :auxiliary_metasploit_module_class_new,
                "#{auxiliary_metasploit_module_class_new_exception.class} " \
                "#{auxiliary_metasploit_module_class_new_exception}:\n" \
                "#{auxiliary_metasploit_module_class_new_exception.backtrace.join("\n")}"
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