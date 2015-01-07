# Creates the `mc_module_paths` table used by {Metasploit::Cache::Module::Path}.
class CreateMcModulePaths < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # The table begin {#up created}/{#down destroyed}
  TABLE_NAME = :mc_module_paths

  # Drops metasploit_cache_module_paths.
  #
  # @return [void]
  def down
    drop_table TABLE_NAME
  end

  # Create metasploit_cache_module_paths.
  #
  # @return [void]
  def up
    create_table TABLE_NAME do |t|
      t.string :gem, null: true
      t.string :name, null: true
      t.text :real_path, null: false
    end

    change_table TABLE_NAME do |t|
      t.index [:gem, :name], unique: true
      t.index :real_path, unique: true
    end
  end
end
