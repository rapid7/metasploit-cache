# @abstract Subclass and override {#persistent} and {#with_tagged_logger}.  Define a SYNCHRONIZERS constant of type
#   `Enumerable<#<ActiveRecord::Base>synchronize(destination: ActiveRecord::Base, logger:, source:)>` for {#persist} to
#   pass to {Metasploit::Cache::Persister.persist}.
#
# Persists an {#ephemeral} Metasploit Module instance, class, or ancestor ruby Class or Module to a {#persistent}
# `ActiveRecord::Base` instance.
class Metasploit::Cache::Module::Persister < Metasploit::Model::Base
  extend Metasploit::Cache::ResurrectingAttribute

  #
  # Attributes
  #

  # The Metasploit Module being cached.
  #
  # @return [Module]
  attr_accessor :ephemeral

  # Tagged logger to which to log {#persist} errors.
  #
  # @return [ActiveSupport::TaggedLogging]
  attr_accessor :logger

  #
  # Resurrecting Attributes
  #

  # Cached metadata for this {#metasploit_instance}
  #
  # @return [Metasploit::Cache::Auxiliary::Instance]
  resurrecting_attr_accessor(:persistent) {
    ActiveRecord::Base.connection_pool.with_connection {
      persistent_relation.readonly(false).first
    }
  }

  #
  # Validations
  #

  validates :ephemeral,
            presence: true
  validates :logger,
            presence: true

  #
  # Instance Methods
  #

  # @note This persister should be validated with `valid?` prior to calling {#persist} to ensure that {#logger} is
  #   present in case of error.
  # @note Validation errors for `to` will be logged as errors tagged with one or more
  #   {Metasploit::Cache::Module::Ancestor#real_pathname}(s).
  #
  # Persists metadata from {#ephemeral} and it's {#persistent} store.
  #
  # @param to [ActiveRecord::Base] Save cacheable data to this persistent store.
  # @return [ActiveRecord::Base] `#persisted?` will be `false` if saving fails
  def persist(to: persistent)
    persisted = nil

    ActiveRecord::Base.connection_pool.with_connection do
      with_tagged_logger(to) do |tagged|
        persisted = Metasploit::Cache::Persister.persist destination: to,
                                                         logger: tagged,
                                                         source: ephemeral,
                                                         synchronizers: self.class::SYNCHRONIZERS
      end
    end

    persisted
  end

  protected

  # @abstract Override with a method that returns a query that can that reload {#persistent} from metadata stored on the
  #   persisters (such as the real_path_sha1_hex_digest) of the ancestor(s).
  #
  # @return [ActiveRecord::Relation]
  def persistent_relation
    raise NotImplementedError.new(
              "#{self.class}.#{__method__} must be defined to return an ActiveRecord::Relation, " \
              "which will have `.readonly(false).first` called on it to retrieve #{self.class}#persistent, " \
              'which can be used as the default `to` keyword argument for `#persist`'
          )
  end

  # @abstract {#with_tagger_logger} needs to tag {#logger} with one or more {Metasplpoit::Cache::Module::Ancestor}(s)
  #   using {#persistent} or instance of {#persistent}'s class passed to {#persist}.
  #
  # Tags log with {Metasploit::Cache::Module::Ancestor#real_pathname}(s).
  #
  # @param record [ActiveRecord::Base] an ActiveRecord::Base subclass with an association path to one or more
  #   {Metasploit::Cache::Module::Ancestor}(s).
  # @yield [tagged_logger]
  # @yieldparam tagged_logger [ActiveSupport::TaggedLogger] {#logger} with
  #   {Metasploit::Cache::Module#Ancestor#real_pathname}(s) tag.
  # @yieldreturn [void]
  # @return [void]
  def with_tagged_logger(record, &block)
    raise NotImplementedError.new(
              "#{self.class}.##{__method__} must be defined (as at least protected) to return takes an " \
              'ActiveRecord::Base subclass instance with an association path to one or more ' \
              '{Metasploit::Cache::Module::Ancestor}(s) and a block.  The block should yield {#logger} tagged with ' \
              'one or more {Metasploit::Cache::Module::Ancestor#real_pathname}(s).'
          )
  end
end