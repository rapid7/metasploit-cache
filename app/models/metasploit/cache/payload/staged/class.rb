# A staged payload Metasploit Module that combines a stager payload Metasploit Module that downloads a staged payload
# Metasploit Module.
#
# The stager and stage payload must be compatible.  A stager and stage are compatible if they share some subset of
# architectures and platforms.
class Metasploit::Cache::Payload::Staged::Class < ActiveRecord::Base
  #
  # Associations
  #

  # Stage payload Metasploit Module downloaded by {#payload_stager_instance}.
  belongs_to :payload_stage_instance,
             class_name: 'Metasploit::Cache::Payload::Stage::Instance',
             inverse_of: :payload_staged_classes

  # Stager payload Metasploit Module that exploit Metasploit Module runs on target system and which then downloads
  # {#payload_stage_instance stage payload Metasploit Module} to complete this staged payload Metasploit Module on the
  # target system.
  belongs_to :payload_stager_instance,
             class_name: 'Metasploit::Cache::Payload::Stager::Instance',
             inverse_of: :payload_staged_classes

  #
  # Attributes
  #

  # @!attribute payload_stage_instance_id
  #   Foreign key for {#payload_stage_instance}.
  #
  #   @return [Integer]

  # @!attribute payload_stager_instance_id
  #   Foreign key for {#payload_stager_instance}.
  #
  #   @return [Integer]

  #
  #
  # Validations
  #
  #

  #
  # Method Validations
  #

  validate :compatible_architectures
  validate :compatible_platforms

  #
  # Attribute Validations
  #

  validates :payload_stage_instance,
            presence: true

  validates :payload_stage_instance_id,
            uniqueness: {
                scope: :payload_stager_instance_id
            }

  validates :payload_stager_instance,
            presence: true

  #
  # Instance Methods
  #
  
  # @!method payload_stage_instance_id=(payload_stage_instance_id)
  #   Sets {#payload_stage_instance_id} and invalidates cached {#payload_stage_instance} so it is reloaded on next
  #   access.
  #
  #   @param payload_stage_instance_id [Integer]
  #   @return [void]
  
  # @!method payload_stager_instance_id=(payload_stager_instance_id)
  #   Sets {#payload_stager_instance_id} and invalidates cached {#payload_stager_instance} so it is reloaded on next
  #   access.
  #
  #   @param payload_stager_instance_id [Integer]
  #   @return [void] 

  private

  # The intersection of {#payload_stage_instance} {Metasploit::Cache::Payload::Stage::Instance#architectures} and
  # {#payload_stager_instance} {Metasploit::Cache::Payload::Stager::Instance#architectures}.
  #
  # @return [ActiveRecord::Relation<Metasploit::Cache::Architecture>]
  # @return [nil] unless {#payload_stage_instance} and {#payload_stager_instance} are present
  def architectures
    # TODO replace with ActiveRecord::QueryMethods.none
    if payload_stage_instance && payload_stager_instance
      intersection = payload_stage_instance.architectures.intersect(payload_stager_instance.architectures)
      architecture_table = Metasploit::Cache::Architecture.arel_table

      Metasploit::Cache::Architecture.from(
          architecture_table.create_table_alias(intersection, architecture_table.name)
      )
    end
  end

  # Validates that {#payload_stage_instance} and {#payload_stager_instance} have at least one
  # {Metasploit::Cache::Architecture} in common.
  #
  # @return [void]
  def compatible_architectures
    scope = architectures

    unless scope.nil?
      unless scope.exists?
        errors.add(:base, :incompatible_architectures)
      end
    end
  end

  # Validates taht {#payload_stage_instance} and {#payload_stager_instance} have at least one
  # {Metasploit::Cache::Platform} in common.
  #
  # @return [void]
  def compatible_platforms
    arel = platforms_arel

    unless arel.nil?
      if Metasploit::Cache::Platform.find_by_sql(arel.take(1)).empty?
        errors.add(:base, :incompatible_platforms)
      end
    end
  end

  # @note Cannot return an `ActiveRecord::Relation<Metasploit::Cache::Platform>` because
  #   `Metasploit::Cache::Platform.from` can't take an AREL query containing a Common Table Expression (CTE) `WITH`
  #   clause.
  #
  # The nested set intersection of {#payload_stage_instance} {Metasploit::Cache::Payload::Stage::Instance#platforms} and
  # {#payload_stager_instance} {Metasploit::Cache::Payload::Stager::Instance#platforms}.
  #
  # @return [Arel::SelectManager] An AREL select that will return the platforms supported by this staged payload
  #   Metasploit Module.
  # @return [nil] unless {#payload_stage_instance} and {#payload_stager_instance} are present
  def platforms_arel
    # TODO replace with ActiveRecord::QueryMethods.none
    if payload_stage_instance && payload_stager_instance
      payload_stage_platforms_table = Arel::Table.new(:payload_stage_platforms)
      payload_stager_platforms_table = Arel::Table.new(:payload_stager_platforms)

      payload_stage_platforms_cte = Arel::Nodes::As.new(
          payload_stage_platforms_table,
          # @see https://github.com/rails/arel/issues/309
          Arel.sql("(#{payload_stage_instance.platforms.to_sql})")
      )
      payload_stager_platforms_cte = Arel::Nodes::As.new(
          payload_stager_platforms_table,
          # @see https://github.com/rails/arel/issues/309
          Arel.sql("(#{payload_stager_instance.platforms.to_sql})")
      )
      union = subset_query(payload_stage_platforms_table, payload_stager_platforms_table).union(
          subset_query(payload_stager_platforms_table, payload_stage_platforms_table)
      )

      # union isn't a Arel::SelectManager, so it doesn't respond to `with` so can't use CTE.
      platforms_table = Metasploit::Cache::Platform.arel_table

      union_alias = platforms_table.create_table_alias(
          union,
          platforms_table.name
      )

      platforms_table.from(union_alias).project(
          platforms_table[Arel.star]
      ).with(
          payload_stage_platforms_cte,
          payload_stager_platforms_cte
      )
    end
  end

  # Returns AREL query for the element of the subset table that are (improper) subset of superset table when
  # `superset_table` and `subset_table` are aliases of the same nested set table.
  #
  # @param superset_table [Arel::Table] table that is the superset in the nested set
  # @param subset_table [Arel::Table] table that is the subset in the nested set
  # @return [Arel::SelectManager]
  def subset_query(superset_table, subset_table)
    subset_table.join(
        superset_table
    ).on(
        superset_table[:left].lteq(subset_table[:left]).and(
            superset_table[:right].gteq(subset_table[:right])
        )
    ).project(subset_table[Arel.star])
  end


  Metasploit::Concern.run(self)
end
