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

  # @note This ephemeral cache should be validated with `valid?` prior to calling {#persist_direct_class} to ensure
  #   that {#logger} is present in case of error.
  # @note Validation errors for `direct_class` will be logged as errors tagged with
  #   {Metasploit::Cache::Module::Ancestor#real_pathname}/.
  #
  # @param to [Metasploit::Cache::Direct::Class] Save cacheable data to {Metasploit::Cache::Direct::Class}.
  # @return [Metasploit::Cache::Direct::Class] `#persisted?` will be `false` if saving fails.
  def persist_direct_class(to: direct_class)
    with_direct_class_tag(to) do |tagged|
      name!(direct_class: to)
      # set directly on `to` so that caller can see `nil` value.
      to.rank =  metasploit_class_module_rank(logger: tagged)

      # Ensure that connection is only held temporarily by Thread instead of being memoized to Thread
      saved = ActiveRecord::Base.connection_pool.with_connection {
        to.batched_save
      }

      unless saved
        tagged.error {
          "Could not be persisted to #{to.class}: #{to.errors.full_messages.to_sentence}"
        }
      end
    end

    to
  end

  private

  # Persisted form of {#metasploit_class}'s `rank`.
  #
  # @param logger [ActiveSupport::TaggedLogger] logger already tagged with
  #   {Metasploit::Cache::Module::Ancestor#real_pathname}.
  # @return [Metasploit::Cache::Module::Rank] persisted rank corresponding to {#metasploit_class}'s rank.'
  # @return [nil] if {#metasploit_class} does not respond to `rank`
  # @return [nil] if {#metasploit_class}'s `rank` is not a seeded {Metasploit::Cache::Module::Rank#number}.
  def metasploit_class_module_rank(logger:)
    module_rank = nil

    if metasploit_class.respond_to? :rank
      rank_number = metasploit_class.rank

      # Ensure that connection is only held temporarily by Thread instead of being memoized to Thread
      module_rank = ActiveRecord::Base.connection_pool.with_connection {
        Metasploit::Cache::Module::Rank.where(number: rank_number).first
      }

      if module_rank.nil?
        name = Metasploit::Cache::Module::Rank::NAME_BY_NUMBER[rank_number]

        if name.nil?
          logger.error {
            "Metasploit::Cache::Module::Rank with #number (#{rank_number}) is not in list of allowed #numbers " \
            "(#{Metasploit::Cache::Module::Rank::NAME_BY_NUMBER.keys.sort.to_sentence})"
          }
        else
          logger.error {
            "Metasploit::Cache::Module::Rank with #number (#{rank_number}) is not seeded"
          }
        end
      end
    else
      logger.error {
        "#{metasploit_class} does not respond to rank. " \
        "It should return the `Metasploit::Cache::Module::Rank#number`."
      }
    end

    module_rank
  end

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

  # {Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest} used to resurrect {#direct_class}.
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
  def with_direct_class_tag(direct_class, &block)
    real_path = ActiveRecord::Base.connection_pool.with_connection {
      direct_class.ancestor.real_pathname.to_s
    }

    Metasploit::Cache::Logged.with_tagged_logger(ActiveRecord::Base, logger, real_path, &block)
  end
end
