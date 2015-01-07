class CreateMcModuleTargetArchitectures < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Name of table being created
  TABLE_NAME = :mc_module_target_architectures

  #
  # Methods
  #

  # Drop {TABLE_NAME}.
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
      t.references :architecture, null: false
      t.references :module_target, null: false
    end

    change_table TABLE_NAME do |t|
      t.index [
                  :module_target_id,
                  :architecture_id
              ],
              name: 'unique_mc_module_target_architectures',
              unique: true
    end
  end
end
