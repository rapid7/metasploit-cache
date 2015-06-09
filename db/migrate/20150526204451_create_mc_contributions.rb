class CreateMcContributions < ActiveRecord::Migration
  #
  # CONSTANTS
  #
  # Name of the table being created
  TABLE_NAME = :mc_contributions

  #
  # Instance Methods
  #

  # Drop {TABLE_NAME}.
  #
  # @return [void]
  def down
    drop_table TABLE_NAME
  end

  # Create {TABLE_NAME}.
  #
  # @return [void]
  def up
    create_table TABLE_NAME do |t|
      #
      # References
      #

      t.references :author,
                   null: false
      t.references :contributable,
                   null: false,
                   polymorphic: true
      t.references :email_address,
                   null: true
    end

    change_table TABLE_NAME do |t|
      t.index :author_id,
              unique: false
      t.index [:contributable_type, :contributable_id],
              name: 'mc_contribution_contributables',
              unique: false
      t.index [:contributable_type, :contributable_id, :author_id],
              name: 'unique_mc_contribution_authors',
              unique: true
      t.index [:contributable_type, :contributable_id, :email_address_id],
              name: 'unique_mc_contribution_email_addresses',
              unique: true
      t.index :email_address_id,
              unique: false
    end
  end
end
