class CreateMcModuleAncestors < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # The table being created
  TABLE_NAME = :mc_module_ancestors

  #
  # Methods
  #

  # Drops the module_ancestors table
  #
  # @return [void]
  def down
    drop_table TABLE_NAME
  end

  # Creates the module_ancestors table
  #
  # @return [void]
  def up
    create_table TABLE_NAME do |t|
      #
      # Single Table Inheritance (STI)
      #

      t.string :type

      #
      # Columns
      #

      t.datetime :real_path_modified_at, null: false
      t.string :real_path_sha1_hex_digest, limit: 40, null: false
      t.text :relative_path, null: false

      #
      # References
      #

      t.references :parent_path, null: false
    end

    change_table TABLE_NAME do |t|
      #
      # Foreign Key Indices
      #

      t.index :parent_path_id

      #
      # Unique Indices
      #

      t.index :real_path_sha1_hex_digest, unique: true
      # relative_path is unique because all parent_paths must be able to be unified.
      t.index :relative_path, unique: true
    end
  end
end
