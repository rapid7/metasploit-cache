class CreateMcModuleTargetPlatforms < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Name of table being created
  TABLE_NAME = :mc_module_target_platforms

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
      t.references :module_target, null: false
      t.references :platform, null: false
    end

    change_table TABLE_NAME do |t|
      t.index [
                  :module_target_id,
                  :platform_id,
              ],
              name: 'unique_mc_module_target_platforms',
              unique: true
    end
  end
end
