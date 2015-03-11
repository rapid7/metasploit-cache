# Ephemeral Cache for connecting an in-memory Metasploit Module's ruby Class to its persisted
# {Metasploit::Cache::Module::Class}.
class Metasploit::Cache::Direct::Class::Ephemeral < Metasploit::Model::Base
  extend Metasploit::Cache::ResurrectingAttribute

  #
  # Attributes
  #

  # The subclass of {Metasploit::Cache::Direct::Class} to use to look up {#direct_class}.
  #
  # @return [Class<Metasploit::Cache::Direct::Class>]
  attr_accessor :direct_class_class

  # Tagged logger to which to log {#persist_direct_class} errors.
  #
  # @return [ActiveSupport::TaggedLogging]
  attr_accessor :logger

  # The Metasploit Module's being cached.
  #
  # @return [Class]
  attr_accessor :metasploit_class

  #
  # Resurrecting Attributes
  #

  # Cached metadata for this Class.
  #
  # @return [Metasploit::Cache::Direct::Class]
  resurrecting_attr_accessor :direct_class do
    ActiveRecord::Base.connection_pool.with_connection {
      direct_class_class.where(
          Metasploit::Cache::Module::Ancestor.arel_table[:real_path_sha1_hex_digest].eq(real_path_sha1_hex_digest)
      ).joins(:ancestor).readonly(false).first
    }
  end

  #
  # Validations
  #

  validates :direct_class_class,
            presence: true
  validates :logger,
            presence: true
  validates :metasploit_class,
            presence: true

  #
  # Instance Methods
  #

  # @note This ephemeratl cache should be validated with `valid?` prior to calling {#persist_direct_class} to ensure
  #   that {#logger} is present in case of error.
  # @note Validation errors for `direct_class` will be logged as errors tagged with
  #   {Metasploit::Cache::Module::Ancestor#real_pathname}/.
  #
  # @param to [Metasploit::Cache::Direct::Class] Save cacheable data to {Metasploit::Cache::Direct::Class}.
  # @return [Metasploit::Cache::Direct::Class] `#persisted?` will be `false` if saving fails.
  def persist_direct_class(to: direct_class)
    # set directly on `to` so that caller can see `nil` value.
    to.rank =  metasploit_class_module_rank(direct_class: to)

    # if rank couldn't be retrieved, there's no point attempting to save, which avoid another trip to the database.
    if to.rank
      # Ensure that connection is only held temporarily by Thread instead of being memoized to Thread
      saved = ActiveRecord::Base.connection_pool.with_connection {
        to.batched_save
      }

      unless saved
        log_error(to) {
          "Could not be persisted to #{to.class}: #{to.errors.full_messages.to_sentence}"
        }
      end
    end

    to
  end

  private

  # Logs error to {#logger} tagged with {#direct_class}'s {Metasploit::Cache::Direct::Class#ancestor}'s
  # {Metasploit::Cache::Module::Ancestor#real_pathname}
  #
  # @yield Block called when logger severity is error or worse.
  # @yieldreturn [String] Message to print to log as error if logger severity leel allows for print of ERROR messages.
  # @return [void]
  def log_error(direct_class, &block)
    if logger.error?
      real_path = ActiveRecord::Base.connection_pool.with_connection {
        # accessing ancestor could trigger database connection
        # accessing ancestor.real_pathname could trigger access to {Metasploit::Cache::Module::Ancestor#real_pathname}.
        direct_class.ancestor.real_pathname.to_s
      }

      logger.tagged(real_path) do |tagged|
        tagged.error(&block)
      end
    end
  end

  # Persisted form of {#metasploit_class}'s `rank`.
  #
  # @param direct_class [Metasploit::Cache::Direct::Class] Used to log errors if {#metasploit_class} does not
  #   respond to `rank`.
  # @return [Metasploit::Cache::Module::Rank] persisted rank corresponding to {#metasploit_class}'s rank.'
  # @return [nil] if {#metasploit_class} does not respond to `rank`
  # @return [nil] if {#metasploit_class}'s `rank` is not a seeded {Metasploit::Cache::Module::Rank#number}.
  def metasploit_class_module_rank(direct_class:)
    module_rank = nil

    if metasploit_class.respond_to? :rank
      rank_number = metasploit_class.rank

      # Ensure that connection is only held temporarily by Thread instead of being memoized to Thread
      module_rank = ActiveRecord::Base.connection_pool.with_connection {
        Metasploit::Cache::Module::Rank.where(number: rank_number).first
      }
    else
      log_error(direct_class) {
        "#{metasploit_class} does not respond to rank. " \
        "It should return the `Metasploit::Cache::Module::Rank#number`."
      }
    end

    module_rank
  end

  # {Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest} used to resurrect {#direct_class}.
  #
  # @return [String]
  def real_path_sha1_hex_digest
    metasploit_class.ephemeral_cache_by_source[:ancestor].real_path_sha1_hex_digest
  end
end