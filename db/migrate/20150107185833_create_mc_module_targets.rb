class CreateMcModuleTargets < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Table being changed
  TABLE_NAME = :mc_module_targets

  # Drop `mc_module_targets`.
  #
  # @return [void]
  def down
    drop_table TABLE_NAME
  end

  # Create `mc_module_targets`.
  #
  # @return [void]
  def up
    create_table TABLE_NAME do |t|
      #
      # Columns
      #

      t.integer :index, null: false
      t.text :name, null: false

      #
      # Foreign Keys
      #

      t.references :module_instance, null: false
    end

    change_table TABLE_NAME do |t|
      t.index [:module_instance_id, :name], unique: true
      t.index [:module_instance_id, :index], unique: true
    end
  end
end
