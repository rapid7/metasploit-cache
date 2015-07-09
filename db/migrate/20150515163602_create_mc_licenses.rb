class CreateMcLicenses < ActiveRecord::Migration

  TABLE_NAME = :mc_licenses

  # Drops `mc_licenses`
  #
  # @return [void]
  def down
    drop_table TABLE_NAME
  end

  # Creates `mc_licenses`
  #
  # @return [void]
  def up
    create_table TABLE_NAME do |t|
      t.string :abbreviation, null: false
      t.text :summary, null: true
      t.string :url, null: true
    end

    change_table TABLE_NAME do |t|
      t.index :abbreviation, unique: true
      t.index :summary, unique: true
      t.index :url, unique: true
    end
  end

end
