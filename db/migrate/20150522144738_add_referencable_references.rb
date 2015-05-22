class AddReferencableReferences < ActiveRecord::Migration
  TABLE_NAME = "mc_referencable_references"

  # Create mc_referencable_references and indices
  #
  # @return [void]
  def up
    create_table TABLE_NAME do |t|
      t.references :referencable, polymorphic: true, index: true, null: false
      t.references :reference, null: false, index:true

      t.timestamps
    end

    change_table TABLE_NAME do |t|
      t.index :reference_id
      t.index [:referencable_type, :referencable_id], name: 'mc_referencable_polymorphic'
      t.index [:referencable_type, :referencable_id, :reference_id], unique: true, name: 'unique_mc_referencable_references'
    end
  end

  # Destroy mc_referencable_references and indices
  #
  # @return [void]
  def down
    drop_table TABLE_NAME
  end
end
