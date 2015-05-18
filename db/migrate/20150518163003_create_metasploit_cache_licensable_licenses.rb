class CreateMetasploitCacheLicensableLicenses < ActiveRecord::Migration
  TABLE_NAME = "mc_licensable_licenses"

  # Create mc_licensable_licenses
  # @return [void]
  def up
    create_table TABLE_NAME do |t|
      t.references :licensable, polymorphic: true, index:true, null:false
      t.references :license, null: false, index:true

      t.timestamps
    end
  end

  # Delete mc_licensable_licenses
  # @return [void]
  def down
    drop_table TABLE_NAME
  end
end
