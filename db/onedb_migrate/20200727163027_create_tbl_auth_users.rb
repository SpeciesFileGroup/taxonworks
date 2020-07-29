class CreateTblAuthUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :tblAuthUsers, primary_key: :AuthUserID do |t|
      t.string :Name
      t.string :HashedPassword
      t.string :FullName
      t.integer :TaxaShowSpecs
      t.integer :CiteShowSpecs
      t.integer :SpmnShowSpecs
      t.datetime :LastUpdate
      t.integer :ModifiedBy
      t.datetime :CreatedOn
      t.integer :CreatedBy

      t.index :ModifiedBy
      t.index :CreatedBy
    end
  end
end
