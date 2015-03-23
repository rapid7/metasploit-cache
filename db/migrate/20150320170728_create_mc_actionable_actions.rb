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
      t.string :name,
               null: false

      #
      # References
      #

      t.references :actionable,
                   null: false,
                   polymorphic: true
    end

    change_table TABLE_NAME do |t|
      t.index [:actionable_type, :actionable_id, :name],
              name: :unique_mc_actionable_actions,
              unique: true
    end
  end
end
