class CreateMcModulePlatforms < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Table being created
  TABLE_NAME = :mc_module_platforms

  # Drop `mc_module_platforms`.
  #
  # @return [void]
  def down
    drop_table TABLE_NAME
  end

  # Create `mc_module_platforms`
  #
  # @return [void]
  def up
    create_table TABLE_NAME do |t|
      t.references :module_instance, null: false
      t.references :platform, null: false
    end

    change_table TABLE_NAME do |t|
      t.index [:module_instance_id, :platform_id],
              name: 'unique_mc_module_platforms',
              unique: true
    end
  end
end
