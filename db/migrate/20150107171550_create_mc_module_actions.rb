class CreateMcModuleActions < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # The table being created
  TABLE_NAME = :mc_module_actions

  # Drops `mc_module_actions`
  #
  # @return [void]
  def down
    drop_table TABLE_NAME
  end

  # Creates `mc_module_actions`
  #
  # @return [void]
  def up
    create_table TABLE_NAME do |t|
      #
      # Foreign Keys
      #

      t.references :module_instance, null: false

      #
      # Columns
      #

      t.text :name, null: false
    end

    change_table TABLE_NAME do |t|
      t.index [:module_instance_id, :name], unique: true
    end
  end
end
