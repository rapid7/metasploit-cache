class CreateMcModuleClassNames < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Name of table being created
  TABLE_NAME = :mc_module_class_names

  # Drops {TABLE_NAME}.
  #
  # @return [void]
  def down
    drop_table TABLE_NAME
  end

  # Creates {TABLE_NAME}.
  #
  # @return [void]
  def up
    create_table TABLE_NAME do |t|
      t.string :module_type,
               null: false
      t.string :reference,
               null: false

      #
      # Foreign Keys
      #

      t.references :module_class,
                   null: false,
                   polymorphic: true
    end

    change_table TABLE_NAME do |t|
      t.index [:module_class_type, :module_class_id],
              name: :unique_mc_module_class_name_for_module_class,
              unique: true
      t.index [:module_type, :reference],
              unique: true
    end
  end
end
