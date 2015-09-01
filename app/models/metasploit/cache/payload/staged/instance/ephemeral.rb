# Ephemeral cache for connecting an in-memory staged payload Metasploit Module's ruby instance to its persisted
# {Metasploit::Cache::Payload::Staged::Instance}
class Metasploit::Cache::Payload::Staged::Instance::Ephemeral < Metasploit::Model::Base
  extend Metasploit::Cache::ResurrectingAttribute

  #
  # Attributes
  #

  # The in-memory staged payload Metasploit Module instance being cached.
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
  # @return [Metasploit::Cache::Payload::Staged::Instance]
  resurrecting_attr_accessor(:payload_staged_instance) {
    ActiveRecord::Base.connection_pool.with_connection {
      staged_instances = Metasploit::Cache::Payload::Staged::Instance.arel_table
      staged_classes = Metasploit::Cache::Payload::Staged::Class.arel_table

      stage_classes = Arel::Table.new(:stage_classes)
      stage_ancestors = Arel::Table.new(:stage_ancestors)

      stager_classes = Arel::Table.new(:stager_classes)
      stager_ancestors = Arel::Table.new(:stager_ancestors)

      query = Metasploit::Cache::Payload::Staged::Instance.joins(
          staged_instances.join(
              staged_classes, Arel::InnerJoin
          ).on(
               staged_classes[:id].eq(
                   staged_instances[:payload_staged_class_id]
               )
          ).join(
              Metasploit::Cache::Payload::Stage::Instance.arel_table, Arel::InnerJoin
          ).on(
              Metasploit::Cache::Payload::Stage::Instance.arel_table[:id].eq(
                  Metasploit::Cache::Payload::Staged::Class.arel_table[:payload_stage_instance_id]
              )
          ).join(
               # MUST be aliased because Metasploit::Cache::Payload::Stage::Class and
               #   Metasploit::Cache::Payload::Stager::Class both use mc_direct_classes.
              Metasploit::Cache::Payload::Stage::Class.arel_table.alias(:stage_classes), Arel::InnerJoin
          ).on(
              stage_classes[:id].eq(
                  Metasploit::Cache::Payload::Stage::Instance.arel_table[:payload_stage_class_id]
              )
          ).join(
              Metasploit::Cache::Module::Ancestor.arel_table.alias(:stage_ancestors), Arel::InnerJoin
          ).on(
              stage_ancestors[:id].eq(
                  stage_classes[:ancestor_id]
              )
          ).join_sources
      ).where(
          stage_ancestors[:real_path_sha1_hex_digest].eq(
              ancestor_real_path_sha1_hex_digest(:stage)
          )
      ).joins(
           staged_instances.join(
               staged_classes, Arel::InnerJoin
           ).on(
                staged_classes[:id].eq(
                    staged_instances[:payload_staged_class_id]
                )
           ).join(
              Metasploit::Cache::Payload::Stager::Instance.arel_table, Arel::InnerJoin
          ).on(
              Metasploit::Cache::Payload::Stager::Instance.arel_table[:id].eq(
                  Metasploit::Cache::Payload::Staged::Class.arel_table[:payload_stager_instance_id]
              )
          ).join(
               # MUST be aliased because Metasploit::Cache::Payload::Stage::Class and
               #   Metasploit::Cache::Payload::Stager::Class both use mc_direct_classes.
              Metasploit::Cache::Payload::Stager::Class.arel_table.alias(:stager_classes), Arel::InnerJoin
          ).on(
              stager_classes[:id].eq(
                  Metasploit::Cache::Payload::Stager::Instance.arel_table[:payload_stager_class_id]
              )
          ).join(
              Metasploit::Cache::Module::Ancestor.arel_table.alias(:stager_ancestors), Arel::InnerJoin
          ).on(
              stager_ancestors[:id].eq(
                  stager_classes[:ancestor_id]
              )
          ).join_sources
      ).where(
           stager_ancestors[:real_path_sha1_hex_digest].eq(
               ancestor_real_path_sha1_hex_digest(:stager)
           )
      )

      query.readonly(false).first
    }
  }

  #
  # Validations
  #

  validates :metasploit_module_instance,
            presence: true
  validates :logger,
            presence: true

  #
  # Instance Methods
  #

  # {Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest} from `ancestor` used to resurrect
  # {#payload_staged_instance}.
  #
  # @param source [:stage, :stager] `:stage` to use the
  #   {Metasploit::Cache::Payload::Stage::Instance#payload_stage_class}
  #   {Metasploit::Cache::Payload::Staged:Class#payload_stage_instance} or `:stager` to use the
  #   {Metasploit::Cache::Payload::Stage::Instance#payload_stage_class}
  #   {Metasploit::Cache::Payload::Staged:Class#payload_stager_instance}
  #
  # @return [String]
  def ancestor_real_path_sha1_hex_digest(source)
    metasploit_module_instance.class.ephemeral_cache_by_source.fetch(:class).ancestor_real_path_sha1_hex_digest(source)
  end

  # @note This ephemeral cache should be validated with `#valid?` prior to calling {#persist} to ensure that {#logger}
  #   is present in case of error.
  # @note Validation errors for `payload_stage_class` will be logged as errors tagged with
  #   {Metasploit::Cache::Module::Ancestor#real_pathname} from both
  #   {Metasploit::Cache;:Payload::Staged::Instance#payload_staged_class}
  #   {Metasploit::Cache::Payload::Staged::Class#payload_stage_instance}
  #   {Metasploit::Cache::Payload::Stage::Instance#payload_stage_class}
  #   {Metasploit::Cache::Payload::Stage::Class#ancestor} and
  #   {Metasploit::Cache;:Payload::Staged::Instance#payload_staged_class}
  #   {Metasploit::Cache::Payload::Staged::Class#payload_stager_instance}
  #   {Metasploit::Cache::Payload::Stager::Instance#payload_stager_class}
  #   {Metasploit::Cache::Payload::Stager::Class#ancestor}.
  #
  # @param to [Metasploit::Cache::Payload::Staged::Instance] Sve cacheable data to {Metasploit::Cache::Payload::Staged::Instance}.
  #   Giving `to` saves a database lookup if {#payload_staged_instance} is not loaded.
  # @return [Metasploit::Cache:Payload::Staged::Instance] `#persisted?` will be `false` if saving fails.
  def persist(to: payload_staged_instance)
    with_payload_staged_instance_tag(to) do |tagged|
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

  # Tags log with {Metasploit::Cache::Module::Ancestor#real_pathname} from both
  #   {Metasploit::Cache;:Payload::Staged::Instance#payload_staged_class}
  #   {Metasploit::Cache::Payload::Staged::Class#payload_stage_instance}
  #   {Metasploit::Cache::Payload::Stage::Instance#payload_stage_class}
  #   {Metasploit::Cache::Payload::Stage::Class#ancestor} and
  #   {Metasploit::Cache;:Payload::Staged::Instance#payload_staged_class}
  #   {Metasploit::Cache::Payload::Staged::Class#payload_stager_instance}
  #   {Metasploit::Cache::Payload::Stager::Instance#payload_stager_class}
  #   {Metasploit::Cache::Payload::Stager::Class#ancestor}.
  #
  # @param payload_staged_instance [Metasploit::Cache::Payload::Staged::Instance]
  # @yield [tagged_logger]
  # @yieldparam tagged_logger [ActiveSupport::TaggedLogger] {#logger} with
  #   {Metasploit::Cache::Module#Ancestor#real_pathname} tags.
  # @yieldreturn [void]
  # @return [void]
  def with_payload_staged_instance_tag(payload_staged_instance, &block)
    Metasploit::Cache::Payload::Staged::Class::Ephemeral.with_payload_staged_class_tag(
        logger,
        payload_staged_instance.payload_staged_class,
        &block
    )
  end
end