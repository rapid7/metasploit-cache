class CreateMcLicensableLicenses < ActiveRecord::Migration
  TABLE_NAME = "mc_licensable_licenses"

  # Create mc_licensable_licenses
  # @return [void]
  def up
    create_table TABLE_NAME do |t|
      t.references :licensable, polymorphic: true, index:true, null:false
      t.references :license, null: false, index:true

      t.timestamps
    end

    change_table TABLE_NAME do |t|
      t.index :license_id
      t.index [:licensable_type, :licensable_id], name: 'mc_licensable_polymorphic'
      t.index [:license_id, :licensable_type, :licensable_id], unique: true, name: 'unique_mc_licensable_licenses'
    end
  end

  # Delete mc_licensable_licenses
  # @return [void]
  def down
    drop_table TABLE_NAME
  end
end
