class CreateMcPayloadHandlers < ActiveRecord::Migration
  #
  # CONSTANTS
  #
  # Name of the table being created
  TABLE_NAME = :mc_payload_handlers

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
      t.string :handler_type,
               null: false
    end

    change_table TABLE_NAME do |t|
      t.index :handler_type,
              unique: true
    end
  end
end
