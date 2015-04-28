class CreateMcPostInstances < ActiveRecord::Migration
  #
  # CONSTANTS
  #
  # Name of the table being created
  TABLE_NAME = :mc_post_instances

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
      t.date :disclosed_on,
             null: false
      t.string :name,
               null: false

      #
      # References
      #

      t.references :post_class,
                   null: false
    end

    change_table TABLE_NAME do |t|
      t.index :post_class_id,
              unique: true
    end
  end
end
