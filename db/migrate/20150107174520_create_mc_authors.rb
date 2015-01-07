class CreateMcAuthors < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Name of the table being created
  TABLE_NAME = :mc_authors

  #
  # Methods
  #

  # Drops `mc_authors`
  #
  # @return [void]
  def down
    drop_table TABLE_NAME
  end

  # Creates `mc_authors`
  #
  # @return [void]
  def up
    create_table TABLE_NAME do |t|
      t.string :name, null: false
    end

    change_table TABLE_NAME do |t|
      t.index :name, unique: true
    end
  end
end
