# Loads a `Metasploit::Cache::*::Instance`
class Metasploit::Cache::Module::Instance::Load < Metasploit::Model::Base
  #
  # Attributes
  #

  # Tagged logger to which to load loading errors.
  #
  # @return [ActiveSupport::TaggedLogging]
  attr_accessor :logger

  # Framework that {#metasploit_module_class} `#initialize` can access Metasploit Framework world state.
  #
  # @return [#events]
  attr_accessor :metasploit_framework

  # `Metasploit<n>` ruby `Class` declared in {Metasploit::Cache::Module::Ancestor#contents}.
  #
  # @return [Class, #framework=]
  attr_accessor :metasploit_module_class

  # Exception raised when `new` is called on {#metasploit_module_class}.
  #
  # @return [nil] if {#metasploit_module_instance} has not run yet.
  # @return [nil] if no exception was raised.
  # @return [Exception] if exception was raised.
  attr_reader :metasploit_module_class_new_exception

  # The module instance being loaded.
  #
  # @return [ActiveRecord::Base]
  attr_accessor :module_instance

  # Persister class
  #
  # @return [#new(metasploit_module_instance: Object, logger: ActiveSupport::TaggedLogging)]
  attr_accessor :persister_class

  #
  #
  # Validations
  #
  #

  #
  # Method Validations
  #

  validate :metasploit_module_class_new_valid,
           unless: :loading_context?

  #
  # Attribute Validations
  #
  
  validates :logger,
            presence: true
  validates :metasploit_framework,
            presence: true
  validates :metasploit_module_class,
            presence: true
  validates :metasploit_module_instance,
            presence: {
                unless: :loading_context?
            }
  validates :module_instance,
            presence: true
  validates :persister_class,
            presence: true

  #
  # Instance Methods
  #

  # Instance of {#metasploit_module_class} loaded into the cache.
  #
  # @return [Metasploit::Cache::Cacheable] if new instance of {#metasploit_module_class} could be loaded into the cache.
  # @return [nil] if new instance of {#metasploit_module_class} could not be created.
  # @return [nil] if new instance of {#metasploit_module_class} could not be persisted to cache.
  def metasploit_module_instance
    unless instance_variable_defined? :@metasploit_module_instance
      if valid?(:loading)
        @metasploit_module_instance = nil

        instance = metasploit_module_class_new

        if instance
          instance.extend Metasploit::Cache::Cacheable
          persister = persister_class.new(
              metasploit_module_instance: instance,
              logger: logger
          )
          instance.persister_by_source[:instance] = persister

          if persister.valid?
            persister.persist(to: module_instance)

            if module_instance.persisted?
              @metasploit_module_instance = instance
            end
          end
        end
      end
    end

    @metasploit_module_instance
  end

  private

  # Attempts to instantiate {#metasploit_module_class}.
  #
  # @return [Object] instance of {#metasploit_module_class}
  # @return [nil] if not valid for loading
  # @return [nil] if exception is raise when `metasploit_module_class.new` is called.
  #   Exception is saved to `metasploit_module_class_new_exception`.
  def metasploit_module_class_new
    begin
      metasploit_module_class.framework = metasploit_framework

      metasploit_module_class.new
    rescue Interrupt
      # handle Interrupt as pass-through unlike other Exceptions so users can bail with Ctrl+C
      raise
    rescue Exception => exception
      @metasploit_module_class_new_exception = exception

      nil
    end
  end

  # Copies error in {#metasploit_module_class_new_exception} to validation error on `:metasploit_module_class`.
  #
  # @return [void]
  def metasploit_module_class_new_valid
    # ensure metasploit_module_instance loading is attempted prior to check if there was an exception.  This ensures
    # there is no dependency on validation order.
    metasploit_module_instance

    if metasploit_module_class_new_exception
      errors.add(
                :metasploit_module_class_new,
                "#{metasploit_module_class_new_exception.class} " \
                "#{metasploit_module_class_new_exception}:\n" \
                "#{metasploit_module_class_new_exception.backtrace.join("\n")}"
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