# Ephemeral Cache for connecting an in-memory single payload Metasploit Module's ruby Class to its persisted
# {Metasploit::Cache::Payload::Single::Handled::Class}.
class Metasploit::Cache::Payload::Single::Handled::Class::Ephemeral < Metasploit::Model::Base
  extend Metasploit::Cache::ResurrectingAttribute

  #
  # Attributes
  #

  # Tagged logger to which to log {#persist} errors.
  #
  # @return [ActiveSupport::TaggedLogging]
  attr_accessor :logger

  # The Metasploit Module being cached.
  #
  # @return [Class]
  attr_accessor :payload_single_handled_metasploit_module_class

  #
  # Resurrecting Attributes
  #

  # Cached metadata for this Class.
  #
  # @return [Metasploit::Cache::Direct::Class]
  resurrecting_attr_accessor :payload_single_handled_class do
    ActiveRecord::Base.connection_pool.with_connection {
      Metasploit::Cache::Payload::Single::Handled::Class.joins(
          payload_single_unhandled_instance: {
              payload_single_unhandled_class: :ancestor
          }
      ).where(
           Metasploit::Cache::Module::Ancestor.arel_table[:real_path_sha1_hex_digest].eq(real_path_sha1_hex_digest)
      ).readonly(false).first
    }
  end

  #
  # Validations
  #

  validates :logger,
            presence: true
  validates :payload_single_handled_metasploit_module_class,
            presence: true

  #
  # Class Methods
  #

  # Tags log with {Metasploit::Cache::Payload::Single::Handled::Class#payload_single_unhandled_instance}
  # {Metasploit::Cache::Payload::Single::Unhandled::Instance#payload_single_unhandled_class}
  # {Metasploit::Cache::Payload::Single::Unhandled::Class#ancestor} {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param logger [ActiveSupport::TaggedLoggin]
  # @param payload_single_handled_class [Metasploit::Cache::Payload::Single::Unhandled::Class]
  # @yield [tagged_logger]
  # @yieldparam tagged_logger [ActiveSupport::TaggedLogger] {#logger} with
  #   {Metasploit::Cache::Module#Ancestor#real_pathname} tags.
  # @yieldreturn [void]
  # @return [void]
  def self.with_tagged_logger(logger, payload_single_handled_class, &block)
    Metasploit::Cache::Module::Ancestor::Ephemeral.with_tagged_logger(
        logger,
        payload_single_handled_class.payload_single_unhandled_instance.payload_single_unhandled_class.ancestor,
        &block
    )
  end

  #
  # Instance Methods
  #

  # @note This ephemeral cache should be validated with `valid?` prior to calling {#persist} to ensure that {#logger} is
  #   present in case of error.
  # @note Validation errors for `payload_single_handled_class` will be logged as errors tagged with
  #   {Metasploit::Cache::Payload::Single::Handled::Class#payload_single_unhandled_instance}
  #   {Metasploit::Cache::Payload::Single::Unhandled::Instance#payload_single_unhandled_class}
  #   {Metasploit::Cache::Payload::Single::Unhandled::Class#ancestor}
  #   {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param to [Metasploit::Cache::Payload::Single::Handled::Class] Save cacheable data to
  #   {Metasploit::Cache::Payload::Single::Handled::Class}.
  # @return [Metasploit::Cache::Payload::Single::Handled::Class] `#persisted?` will be `false` if saving fails.
  def persist(to: payload_single_handled_class)
    persisted = nil

    ActiveRecord::Base.connection_pool.with_connection do
      with_tagged_logger(to) do |tagged|
        name!(payload_single_handled_class: to)

        persisted = Metasploit::Cache::Ephemeral.persist logger: tagged,
                                                         record: to
      end
    end

    persisted
  end

  private

  # Builds `#name` for `payload_single_handled_class`.
  #
  # @param payload_single_handled_class [Metasploit::Cache::Payload::Single::Handled::Class, #build_name, #class, #reference_name]
  #
  # @return [void]
  def name!(payload_single_handled_class:)
    payload_single_handled_class.build_name(
        module_type: 'payload',
        reference: payload_single_handled_class.reference_name
    )
  end

  # {Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest} used to resurrect {#payload_single_handled_class}.
  #
  # @return [String]
  def real_path_sha1_hex_digest
    payload_single_handled_metasploit_module_class.ephemeral_cache_by_source.fetch(:ancestor).real_path_sha1_hex_digest
  end

  # Tags log with {Metasploit::Cache::Payload::Single::Handled::Class#payload_single_unhandled_instance}
  # {Metasploit::Cache::Payload::Single::Unhandled::Instance#payload_single_unhandled_class}
  # {Metasploit::Cache::Payload::Single::Unhandled::Class#ancestor} {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param payload_single_handled_class [Metasploit::Cache::Payload::Single::Unhandled::Class]
  # @yield [tagged_logger]
  # @yieldparam tagged_logger [ActiveSupport::TaggedLogger] {#logger} with
  #   {Metasploit::Cache::Module#Ancestor#real_pathname} tags.
  # @yieldreturn [void]
  # @return [void]
  def with_tagged_logger(payload_single_handled_class, &block)
    self.class.with_tagged_logger(logger, payload_single_handled_class, &block)
  end
end
