class CreateMcPayloadStagerAncestorHandler < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Name of table being created
  TABLE_NAME = :mc_payload_stager_ancestor_handlers

  # Drops {TABLE}.
  #
  # @return [void]
  def down
    drop_table TABLE_NAME
  end

  # Creates {TABLE}.
  #
  # @return [void]
  def up
    create_table TABLE_NAME do |t|
      t.string :type_alias,
               null: false

      #
      # Foreign Keys
      #

      t.references :payload_stager_ancestor,
                   null: false
    end

    change_table TABLE_NAME do |t|
      t.index :payload_stager_ancestor_id,
              name: :unique_mc_payload_stager_ancestor_handlers,
              unique: true
    end
  end
end
