class CreateMcPayloadSingleHandledInstances < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # The name of the table being created
  TABLE_NAME = :mc_payload_single_handled_instances

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
  def change
    create_table TABLE_NAME do |t|
      t.references :payload_single_handled_class,
                   null: false
    end

    change_table TABLE_NAME do |t|
      t.index :payload_single_handled_class_id,
              name: :unique_payload_single_handled_instances,
              unique: true
    end
  end
end
