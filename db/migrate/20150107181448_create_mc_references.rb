class CreateMcReferences < ActiveRecord::Migration
  #
  # CONSTANTS
  #

  # Table being created
  TABLE_NAME = :mc_references

  #
  # Methods
  #

  # Drops `mc_references`
  #
  # @return [void]
  def down
    drop_table TABLE_NAME
  end

  # Creates `mc_references`
  #
  # @return [void]
  def up
    # All columns can be null because either authority_id and designation OR url must be non-null, but that is only
    # handled in Rails
    create_table TABLE_NAME do |t|
      #
      # Columns
      #

      t.string :designation, null: true
      t.text :url, null: true

      #
      # Foreign Keys
      #

      t.references :authority, null: true
    end

    change_table TABLE_NAME do |t|
      t.index [:authority_id, :designation], unique: true
      t.index :url, unique: true
    end
  end
end
