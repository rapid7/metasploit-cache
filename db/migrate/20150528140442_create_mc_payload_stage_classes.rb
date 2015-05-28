class CreateMcPayloadStageClasses < ActiveRecord::Migration
  #
  # CONSTANTS
  #
  # Name of the table being created
  TABLE_NAME = :mc_payload_staged_classes

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

      t.references :payload_stage_instance,
                   null: false
      t.references :payload_stager_instance,
                   null: false
    end

    change_table TABLE_NAME do |t|
      t.index :payload_stage_instance_id,
              unique: false
      t.index :payload_stager_instance_id,
              unique: false
      t.index [:payload_stager_instance_id, :payload_stage_instance_id],
              name: 'unique_mc_payload_staged_classes',
              unique: true
    end
  end
end
