class CreateMcPayloadSingleHandledClasses < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # The name of the table being created
  TABLE_NAME = :mc_payload_single_handled_classes

  #
  # Instance Methods
  #

  # Drops {TABLE_NAME}.
  #
  # @return [void]
  def down
    drop_table TABLE_NAME
  end

  def up
    create_table TABLE_NAME  do |t|
      t.references :payload_single_unhandled_instance,
                   null: false
    end

    change_table TABLE_NAME do |t|
      t.index :payload_single_unhandled_instance_id,
              name: :unique_mc_payload_single_handled_classes,
              unique: true
    end
  end
end
