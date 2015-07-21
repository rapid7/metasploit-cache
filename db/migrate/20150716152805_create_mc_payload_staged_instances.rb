class CreateMcPayloadStagedInstances < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Name of the table being created
  TABLE_NAME = :mc_payload_staged_instances

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

      t.references :payload_staged_class,
                   null: false
    end

    change_table TABLE_NAME do |t|
      t.index :payload_staged_class_id,
              unique: true
    end
  end
end
