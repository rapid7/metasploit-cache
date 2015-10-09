# Ephemeral Cache for connecting an in-memory Metasploit Module's ruby Class to its persisted
# {Metasploit::Cache::Module::Class}.
class Metasploit::Cache::Direct::Class::Ephemeral < Metasploit::Model::Base
  extend Metasploit::Cache::ResurrectingAttribute

  #
  # Attributes
  #

  # The subclass of {Metasploit::Cache::Direct::Class} to use to look up {#persistent}.
  #
  # @return [Class<Metasploit::Cache::Direct::Class>]
  attr_accessor :persistent_class

  # Tagged logger to which to log {#persist} errors.
  #
  # @return [ActiveSupport::TaggedLogging]
  attr_accessor :logger

  # The Metasploit Module being cached.
  #
  # @return [Class]
  attr_accessor :metasploit_class

  #
  # Resurrecting Attributes
  #

  # Cached metadata for this Class.
  #
  # @return [Metasploit::Cache::Direct::Class]
  resurrecting_attr_accessor(:persistent) {
    ActiveRecord::Base.connection_pool.with_connection {
      persistent_class.where(
          Metasploit::Cache::Module::Ancestor.arel_table[:real_path_sha1_hex_digest].eq(real_path_sha1_hex_digest)
      ).joins(:ancestor).readonly(false).first
    }
  }

  #
  # Validations
  #

  validates :metasploit_class,
            presence: true
  validates :persistent_class,
            presence: true
  validates :logger,
            presence: true

  #
  # Instance Methods
  #

  # @note This ephemeral cache should be validated with `valid?` prior to calling {#persist} to ensure
  #   that {#logger} is present in case of error.
  # @note Validation errors for `persistent` will be logged as errors tagged with
  #   {Metasploit::Cache::Module::Ancestor#real_pathname}/.
  #
  # @param to [Metasploit::Cache::Direct::Class] Save cacheable data to {Metasploit::Cache::Direct::Class}.
  # @return [Metasploit::Cache::Direct::Class] `#persisted?` will be `false` if saving fails.
  def persist(to: persistent)
    persisted = nil

    ActiveRecord::Base.connection_pool.with_connection do
      with_tagged_logger(to) do |tagged|
        name!(direct_class: to)

        synchronized = Metasploit::Cache::Module::Class::Ephemeral::Rank.synchronize(
            destination: to,
            logger: tagged,
            source: metasploit_class
        )

        persisted = Metasploit::Cache::Ephemeral.persist(logger: tagged, record: synchronized)
      end
    end

    persisted
  end

  private

  # Builds `#name` for `direct_class`.
  #
  # @param direct_class [Metasploit::Cache::Direct::Class, #reference_name, #class] Used to log errors if
  #   `direct_class`.
  # @return [void]
  def name!(direct_class:)
    direct_class.build_name(
        module_type: direct_class.class::MODULE_TYPE,
        reference: direct_class.reference_name
    )
  end

  # {Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest} used to resurrect {#persistent}.
  #
  # @return [String]
  def real_path_sha1_hex_digest
    metasploit_class.ephemeral_cache_by_source[:ancestor].real_path_sha1_hex_digest
  end

  # Tags log with {Metasploit::Cache::Direct::Class#ancestor} {Metasploit::Cache::Module::Ancestor#real_pathname}.
  #
  # @param direct_class [Metasploit::Cache::Direct::Class, #ancestor]
  # @yield [tagged_logger]
  # @yieldparam tagged_logger [ActiveSupport::TaggedLogger] {#logger} with
  #   {Metasploit::Cache::Module#Ancestor#real_pathname} tag.
  # @yieldreturn [void]
  # @return [void]
  def with_tagged_logger(direct_class, &block)
    Metasploit::Cache::Module::Ancestor::Ephemeral.with_tagged_logger(logger, direct_class.ancestor, &block)
  end
end
