class CreateMcPlatformablePlatforms < ActiveRecord::Migration
  #
  # CONSTANTS
  #
  # Name of the table being created
  TABLE_NAME = :mc_platformable_platforms

  #
  # Instance Methods
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
      #
      # References
      #

      t.references :platform,
                   null: false
    end

    change_table TABLE_NAME do |t|
      t.index :platform_id,
              unique: false
    end
  end
end
