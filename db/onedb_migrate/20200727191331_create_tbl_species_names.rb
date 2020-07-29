class CreateTblSpeciesNames < ActiveRecord::Migration[6.0]
  def change
    create_table :tblSpeciesNames, primary_key: :SpeciesNameID do |t|
      t.integer :FileID
      t.string :Name
      t.boolean :Italicize
      t.datetime :LastUpdate
      t.integer :ModifiedBy
      t.datetime :CreatedOn
      t.integer :CreatedBy

      t.index :FileID
      t.index [:FileID, :Name]
      t.index :ModifiedBy
      t.index :CreatedBy
    end
  end
end
