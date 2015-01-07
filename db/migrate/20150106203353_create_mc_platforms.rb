class CreateMcPlatforms < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Table being created
  TABLE_NAME = :mc_platforms

  #
  # Methods
  #

  # Drops `mc_platforms`.
  #
  # @return [void]
  def down
    drop_table TABLE_NAME
  end

  # Removes named platforms and replaces them with nested set platforms that can represent platform hiearchy used by
  # metasploit-framework.
  def up
    # create nested platforms
    create_table TABLE_NAME do |t|
      # platform specific columns
      t.text :fully_qualified_name, null: false
      t.text :relative_name, null: false

      # nested set columns
      t.references :parent, null: true
      t.integer :right, null: false
      t.integer :left, null: false
    end

    change_table TABLE_NAME do |t|
      t.index :fully_qualified_name, unique: true
      t.index [:parent_id, :relative_name], unique: true
    end
  end
end
