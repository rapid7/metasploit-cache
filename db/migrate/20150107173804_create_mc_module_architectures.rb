class CreateMcModuleArchitectures < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Name of the table being created
  TABLE_NAME = :mc_module_architectures

  # Drops `mc_module_architectures`.
  #
  # @return [void]
  def down
    drop_table TABLE_NAME
  end

  # Creates `mc_module_architectures`.
  #
  # @return [void]
  def up
    create_table TABLE_NAME do |t|
      t.references :architecture, null: false
      t.references :module_instance, null: false
    end

    change_table TABLE_NAME do |t|
      t.index [:module_instance_id, :architecture_id],
              # 'index_mc_module_architectures_on_module_instance_id_and_architecture_id' is longer than 63 character
              # limit
              name: 'unique_mc_module_architectures',
              unique: true
    end
  end
end
