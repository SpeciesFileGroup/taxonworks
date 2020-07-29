class CreateTblCites < ActiveRecord::Migration[6.0]
  def change
    create_table :tblCites do |t|
      t.integer :TaxonNameID
      t.integer :SeqNum
      t.integer :RefID
      t.string :CitePages
      t.string :Note
      t.integer :NomenclatorID
      t.integer :NewNameStatusID
      t.integer :TypeInfoID
      t.integer :ConceptChangeID
      t.boolean :CurrentConcept
      t.integer :InfoFlags
      t.integer :InfoFlagStatus
      t.integer :PolynomialStatus
      t.datetime :LastUpdate
      t.integer :ModifiedBy
      t.datetime :CreatedOn
      t.integer :CreatedBy

      t.index [:TaxonNameID, :SeqNum]
      t.index :RefID
      t.index :NomenclatorID
      t.index :NewNameStatusID
      t.index :TypeInfoID
      t.index :ConceptChangeID

      t.index :ModifiedBy
      t.index :CreatedBy
    end
  end
end
