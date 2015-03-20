class CreateMcAuxiliaryInstances < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Name of the table being created
  TABLE_NAME = :mc_auxiliary_instances

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
      t.references :auxiliary_class, null: false
    end

    change_table TABLE_NAME do |t|
      t.index :auxiliary_class_id, unique: true
    end
  end
end