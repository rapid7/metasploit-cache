class CreateMcModuleReferences < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Table being created
  TABLE_NAME = :mc_module_references

  #
  # Methods
  #

  # Drops `mc_module_references`
  #
  # @return [void]
  def down
    drop_table TABLE_NAME
  end

  # Creates `mc_module_references`
  #
  # @return [void]
  def up
    create_table TABLE_NAME do |t|
      t.references :module_instance, null: false
      t.references :reference, null: false
    end

    change_table TABLE_NAME do |t|
      t.index [:module_instance_id, :reference_id],
              # 'index_mc_module_references_on_module_instance_id_and_reference_id' is longer than 63 character limit
              name: 'unique_mc_module_references',
              unique: true
    end
  end
end
