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

      t.references :platformable,
                   null: false,
                   polymorphic: true
      t.references :platform,
                   null: false
    end

    change_table TABLE_NAME do |t|
      t.index :platform_id,
              unique: false
      t.index [:platformable_type, :platformable_id],
              name: 'mc_platformable_platformables',
              unique: false
      t.index [:platformable_type, :platformable_id, :platform_id],
              name: 'unique_mc_platformable_platforms',
              unique: true
    end
  end
end
