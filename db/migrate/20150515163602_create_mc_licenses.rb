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
      t.string :abbreviation, null: false, unique: true
      t.text :summary, null: false, unique: true
      t.string :url, null: false, unique: true
    end
  end

end
