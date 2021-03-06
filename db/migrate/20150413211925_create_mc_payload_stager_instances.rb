class CreateMcPayloadStagerInstances < ActiveRecord::Migration
  #
  # CONSTANTS
  #
  # Name of the table being created
  TABLE_NAME = :mc_payload_stager_instances

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
      t.text :description,
             null: false
      t.string :name,
               null: false
      t.boolean :privileged,
                null: false

      #
      # References
      #

      t.references :handler,
                   null: false
      t.references :payload_stager_class,
                   null: false
    end

    change_table TABLE_NAME do |t|
      t.index :handler_id,
              unique: false
      t.index :payload_stager_class_id,
              unique: true
    end
  end
end
