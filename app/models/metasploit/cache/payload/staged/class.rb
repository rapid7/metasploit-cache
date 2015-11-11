# A staged payload Metasploit Module that combines a stager payload Metasploit Module that downloads a staged payload
# Metasploit Module.
#
# The stager and stage payload must be compatible.  A stager and stage are compatible if they share some subset of
# architectures and platforms.
class Metasploit::Cache::Payload::Staged::Class < ActiveRecord::Base
  extend ActiveSupport::Autoload

  include Metasploit::Cache::Batch::Root
  include Metasploit::Cache::Module::Class::Namable

  autoload :Persister
  autoload :Load

  #
  # Associations
  #

  # Stage payload Metasploit Module downloaded by {#payload_stager_instance}.
  belongs_to :payload_stage_instance,
             class_name: 'Metasploit::Cache::Payload::Stage::Instance',
             inverse_of: :payload_staged_classes

  # Staged payload Metasploit Module combining {#payload_staged_instance} and {#payload_stager_instance}.
  has_one :payload_staged_instance,
          class_name: 'Metasploit::Cache::Payload::Staged::Instance',
          dependent: :destroy,
          foreign_key: :payload_staged_class_id,
          inverse_of: :payload_staged_class

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
  # Class Methods
  #

  # Binds combined bind values from subqueries onto the combined query's relation.
  #
  # @param relation [ActiveRecord::Relation] Relation that does not have bind_values for `Arel::Nodes::BindParam`s.
  # @param bind_values [Array<Array(ActiveRecord::ConnectionAdapters::Column, Object)>] Array of bind values
  #   (pairs of columns and values) for the combined query.  Must be in order of final query.
  # @return [ActiveRecord::Relation] a new relation with values bound.
  def self.bind_renumbered_bind_params(relation, bind_values)
    bind_values.reduce(relation) { |bound_relation, bind_value|
      bound_relation.bind(bind_value)
    }
  end

  # Renumbers the `Arel::Nodes::BindParam`s when combining subquery
  #
  # @param node [Arel::Nodes::Node, #grep] a Arel node that has `Arel::Nodes::BindParam` findable with `#grep`.
  # @param bind_values [Array<Array(ActiveRecord::ConnectionAdapters::Column, Object)>] Array of bind values
  #   (pairs of columns and values) for the combined query.  Must be in order of final query.
  # @param start [Integer] The starting index to look up in `bind_values`.
  # @return [Integer] the `start` for the next call to `renumber_bind_params`
  def self.renumber_bind_params(node, bind_values, start=0)
    index = start

    node.grep(Arel::Nodes::BindParam) do |bind_param|
      column = bind_values[index].first
      bind_param.replace connection.substitute_at(column, index)
      index += 1
    end

    index
  end

  # Scope matching {Metasploit::Cache::Payload::Staged::Class} where the `type` ancestor has the given
  # `real_path_sha1_hex_digest`.
  #
  # @param type [:stage, :stager] The type of ancestor.
  # @param real_path_sha1_hex_digest [String] the {Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest}.
  # @return [ActiveRecord::Relation<Metasploit::Cache::Payload::Staged::Class>]
  def self.where_ancestor_real_path_sha1_hex_digest(type, real_path_sha1_hex_digest)
    type_namespace = "Metasploit::Cache::Payload::#{type.to_s.camelize}".constantize
    type_instances = type_namespace::Instance.arel_table

    type_classes = type_namespace::Class.arel_table
    type_classes_alias_name = "#{type}_classes".to_sym
    type_classes_alias = Arel::Table.new(type_classes_alias_name)

    type_ancestors = type_namespace::Ancestor.arel_table
    type_ancestors_alias_name = "#{type}_ancestors".to_sym
    type_ancestors_alias = Arel::Table.new(type_ancestors_alias_name)

    joins(
        arel_table.join(
            type_instances, Arel::InnerJoin
        ).on(
            type_instances[:id].eq(
                arel_table[:"payload_#{type}_instance_id"]
            )
        ).join(
            # MUST be aliased because Metasploit::Cache::Payload::Stage::Class and
            #   Metasploit::Cache::Payload::Stager::Class both use mc_direct_classes.
            type_classes.alias(type_classes_alias_name), Arel::InnerJoin
        ).on(
            type_classes_alias[:id].eq(
                type_instances[:"payload_#{type}_class_id"]
            )
        ).join(
            type_ancestors.alias(type_ancestors_alias_name), Arel::InnerJoin
        ).on(
            type_ancestors_alias[:id].eq(
                type_classes_alias[:ancestor_id]
            )
        ).join_sources
    ).where(
        type_ancestors_alias[:real_path_sha1_hex_digest].eq(
            real_path_sha1_hex_digest
        )
    )
  end

  # Scope matching {Metasploit::Cache::Payload::Staged::Class} where the ancestors have the given
  # {Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest}.
  #
  # @param stage [String] {Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest} for
  #   {Metasploit::Cache::Payload::Stage::Ancestor}.
  # @param stager [String] {Metasploit::Cache::Module::Ancestor#real_path_sha1_hex_digest} for
  #   {Metasploit::Cache::Payload::Stage::Ancestor}.
  # @return [ActiveRecord::Relation<Metasploit::Cache::Payload::Staged::Class>]
  def self.where_ancestor_real_path_sha1_hex_digests(stage:, stager:)
    where_ancestor_real_path_sha1_hex_digest(
        :stage,
        stage
    ).where_ancestor_real_path_sha1_hex_digest(
        :stager,
        stager
    )
  end

  #
  # Instance Methods
  #

  # Whether the architectures and platforms from the {#payload_stage_instance} and {#payload_stager_instance} are
  # compatible.
  #
  # @return [true] if architectures and platforms are compatible
  # @return [false] if archtiectures and/or platforms are incompatible
  def compatible?
    architectures_compatible? && platforms_compatible?
  end

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
      payload_stage_architectures = payload_stage_instance.architectures
      payload_stager_architectures = payload_stager_instance.architectures

      # @see https://github.com/rails/rails/commit/2e6625fb775783cdbc721391be18a073a5b9a9c8
      bind_values = payload_stage_architectures.bind_values + payload_stager_architectures.bind_values

      intersection = payload_stage_instance.architectures.intersect(payload_stager_instance.architectures)

      [:left, :right].reduce(0) { |start, side|
        operand = intersection.send(side)

        self.class.renumber_bind_params(operand, bind_values, start)
      }

      architecture_table = Metasploit::Cache::Architecture.arel_table

      relation = Metasploit::Cache::Architecture.from(
          architecture_table.create_table_alias(intersection, architecture_table.name)
      )
      self.class.bind_renumbered_bind_params(relation, bind_values)
    end
  end

  # @return [true] if platforms are compatible or if {#payload_stage_instance} or {#payload_stager_instance} are not
  #   set.
  # @return [false]
  def architectures_compatible?
    scope = architectures

    scope.nil? || scope.exists?
  end

  # Validates that {#payload_stage_instance} and {#payload_stager_instance} have at least one
  # {Metasploit::Cache::Architecture} in common.
  #
  # @return [void]
  def compatible_architectures
    unless architectures_compatible?
      errors.add(:base, :incompatible_architectures)
    end
  end

  # Validates taht {#payload_stage_instance} and {#payload_stager_instance} have at least one
  # {Metasploit::Cache::Platform} in common.
  #
  # @return [void]
  def compatible_platforms
    unless platforms_compatible?
      errors.add(:base, :incompatible_platforms)
    end
  end

  # @note Cannot return an `ActiveRecord::Relation<Metasploit::Cache::Platform>` because
  #   `Metasploit::Cache::Platform.from` can't take an AREL query containing a Common Table Expression (CTE) `WITH`
  #   clause.
  #
  # The nested set intersection of {#payload_stage_instance} {Metasploit::Cache::Payload::Stage::Instance#platforms} and
  # {#payload_stager_instance} {Metasploit::Cache::Payload::Stager::Instance#platforms}.
  #
  # @return [Array(Arel::SelectManager, Array<Array(ActiveRecord::ConnectionAdapters::Column, Object)>)] An AREL select
  #   that will return the platforms supported by this staged payload Metasploit Module along with the bind values for
  #   any `Arel::Nodes::BindParam`s in the `Arel::SelectManager`.
  # @return [nil] unless {#payload_stage_instance} and {#payload_stager_instance} are present
  def platforms_arel_and_bind_values
    # TODO replace with ActiveRecord::QueryMethods.none
    if payload_stage_instance && payload_stager_instance
      payload_stage_platforms_table = Arel::Table.new(:payload_stage_platforms)
      payload_stager_platforms_table = Arel::Table.new(:payload_stager_platforms)

      payload_stage_platforms_relation = payload_stage_instance.platforms
      payload_stager_platforms_relation = payload_stager_instance.platforms

      bind_values = payload_stage_platforms_relation.bind_values + payload_stager_platforms_relation.bind_values

      payload_stage_platforms_cte = Arel::Nodes::As.new(
          payload_stage_platforms_table,
          payload_stage_platforms_relation.arel
      )

      start = self.class.renumber_bind_params(payload_stage_platforms_cte.right.ast, bind_values)

      payload_stager_platforms_cte = Arel::Nodes::As.new(
          payload_stager_platforms_table,
          payload_stager_platforms_relation.arel
      )

      self.class.renumber_bind_params(payload_stager_platforms_cte.right.ast, bind_values, start)

      union = subset_query(payload_stage_platforms_table, payload_stager_platforms_table).union(
          subset_query(payload_stager_platforms_table, payload_stage_platforms_table)
      )

      # union isn't a Arel::SelectManager, so it doesn't respond to `with` so can't use CTE.
      platforms_table = Metasploit::Cache::Platform.arel_table

      union_alias = platforms_table.create_table_alias(
          union,
          platforms_table.name
      )

      arel = platforms_table.from(union_alias).project(
          platforms_table[Arel.star]
      ).with(
          payload_stage_platforms_cte,
          payload_stager_platforms_cte
      )

      [arel, bind_values]
    end
  end

  def platforms_compatible?
    arel_and_bind_values = platforms_arel_and_bind_values
    compatible = true

    unless arel_and_bind_values.nil?
      arel, bind_values = arel_and_bind_values

      if Metasploit::Cache::Platform.find_by_sql(arel.take(1), bind_values).empty?
        compatible = false
      end
    end

    compatible
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
