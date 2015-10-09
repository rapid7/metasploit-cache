# Ephemeral cache for connecting an in-memory single payload Metasploit Module's ruby instance with handler mixed-in to
# its persisted {Metasploit::Cache::Payload::Single::Handled::Instance}
class Metasploit::Cache::Payload::Single::Handled::Instance::Ephemeral < Metasploit::Model::Base
  extend Metasploit::Cache::ResurrectingAttribute

  #
  # Attributes
  #

  # The in-memory single payload Metasploit Module instance with handled mixed-in being cached.
  #
  # @return [Object]
  attr_accessor :metasploit_module_instance

  # Tagged logger to which to log {#persist} errors.
  #
  # @return [ActiveSupport::TaggerLogger]
  attr_accessor :logger

  #
  # Resurrecting Attributes
  #

  # Cached metadata for this {#metasploit_module_instance}.
  #
  # @return [Metasploit::Cache::Payload::Single::Handled::Instance]
  resurrecting_attr_accessor(:payload_single_handled_instance) {
    ActiveRecord::Base.connection_pool.with_connection {
      Metasploit::Cache::Payload::Single::Handled::Instance.joins(
          payload_single_handled_class: {
              payload_single_unhandled_instance: {
                  payload_single_unhandled_class: :ancestor
              }
          }
      ).where(
          Metasploit::Cache::Module::Ancestor.arel_table[:real_path_sha1_hex_digest].eq(real_path_sha1_hex_digest)
      ).readonly(false).first
    }
  }

  #
  # Validations
  #

  validates :logger,
            presence: true
  validates :metasploit_module_instance,
            presence: true

  #
  # Instance Methods
  #

  # @note This ephemeral cache should be validated with `#valid?` prior to calling {#persist} to ensure that {#logger}
  #   is present in case of error.
  # @note Validation errors for `payload_stage_class` will be logged as errors tagged with
  #   {Metasploit::Cache::Payload::Single::Handled::Instance#payload_single_handled_class}
  #   {Metasploit::Cache::Payload::Single::Handled::Class#payload_single_unhandled_instance}
  #   {Metasploit::Cache::Payload::Single::Unhandled::Instance#payload_single_unhandled_class}
  #   {Metasploit::Cache::Payload::Single::Unhandled::Class#ancestor}
  #   {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param to [Metasploit::Cache::Payload::Single::Handled::Instance] Save cacheable data to
  #   {Metasploit::Cache::Payload::Single::Handled::Instance}.
  #   Giving `to` saves a database lookup if {#payload_single_handled_instance} is not loaded.
  # @return [Metasploit::Cache:Payload::Single::Handled::Instance] `#persisted?` will be `false` if saving fails.
  def persist(to: payload_single_handled_instance)
    persisted = nil

    ActiveRecord::Base.connection_pool.with_connection do
      with_tagged_logger(to) do |tagged|
        persisted = Metasploit::Cache::Ephemeral.persist logger: tagged,
                                                         record: to
      end
    end

    persisted
  end

  private

  # {Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest} used to resurrect {#payload_single_handled_class}.
  #
  # @return [String]
  def real_path_sha1_hex_digest
    metasploit_module_instance.class.ephemeral_cache_by_source.fetch(:ancestor).real_path_sha1_hex_digest
  end

  # Tags log with {Metasploit::Cache::Payload::Single::Handled::Class#payload_single_unhandled_instance}
  # {Metasploit::Cache::Payload::Single::Handled::Class#payload_single_unhandled_instance}
  # {Metasploit::Cache::Payload::Single::Unhandled::Instance#payload_single_unhandled_class}
  # {Metasploit::Cache::Payload::Single::Unhandled::Class#ancestor} {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param payload_single_handled_instance [Metasploit::Cache::Payload::Single::Handled::Instance]
  # @yield [tagged_logger]
  # @yieldparam tagged_logger [ActiveSupport::TaggedLogger] {#logger} with
  #   {Metasploit::Cache::Module#Ancestor#real_pathname} tags.
  # @yieldreturn [void]
  # @return [void]
  def with_tagged_logger(payload_single_handled_instance, &block)
    payload_single_handled_class = payload_single_handled_instance.payload_single_handled_class

    Metasploit::Cache::Payload::Single::Handled::Class::Ephemeral.with_tagged_logger(
        logger,
        payload_single_handled_class,
        &block
    )
  end
end