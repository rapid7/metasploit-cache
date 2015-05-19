class CreateMcArchitecturableArchitecture < ActiveRecord::Migration
  #
  # CONSTANTS
  #
  # Name of the table being created
  TABLE_NAME = :mc_architecturable_architectures

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

      t.references :architecture,
                   null: false
    end

    change_table TABLE_NAME do |t|
      t.index :architecture_id,
              unique: false
    end
  end
end
