class CreateMcModuleAuthors < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Table being created
  TABLE_NAME = :mc_module_authors

  # Drop `mc_module_authors`.
  #
  # @return [void]
  def down
    drop_table TABLE_NAME
  end

  # Creates `mc_module_authors` a 3-way join between `mc_authors`, `mc_email_addresses`, and `mc_module_instances`.
  #
  # @return [void]
  def up
    create_table TABLE_NAME do |t|
      t.references :author, null: false
      t.references :email_address, null: true
      t.references :module_instance, null: false
    end

    change_table TABLE_NAME do |t|
      #
      # Foreign Key indices
      #

      t.index :author_id
      t.index :email_address_id
      t.index :module_instance_id

      #
      # Unique indices
      #

      t.index [:module_instance_id, :author_id], unique: true
    end
  end
end
