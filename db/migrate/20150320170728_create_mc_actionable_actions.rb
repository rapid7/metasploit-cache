class CreateMcActionableActions < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Name of the table being created
  TABLE_NAME = :mc_actionable_actions

  #
  # Instance Methods
  #

  # Drop {TABLE_NAME}
  #
  # @return [void]
  def down
    drop_table TABLE_NAME
  end

  # Create {TABLE_NAME}.
  #
  # @return [void]
  def up
    create_table TABLE_NAME do |t|
      t.references :actionable,
                   null: false,
                   polymorphic: true
    end

    change_table TABLE_NAME do |t|
      t.index [:actionable_type, :actionable_id],
              name: :mc_actionable_actions_index
    end
  end
end
