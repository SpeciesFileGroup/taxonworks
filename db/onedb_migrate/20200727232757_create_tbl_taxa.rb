class CreateTblTaxa < ActiveRecord::Migration[6.0]
  def change
    create_table :tblTaxa, primary_key: :TaxonNameID do |t|
      t.integer :FileID
      t.string :TaxonNameStr
      t.integer :RankID
      t.string :Name
      t.boolean :Parens
      t.integer :AboveID
      t.integer :LikeNameID
      t.integer :Extinct
      t.integer :RefID
      t.string :NecAuthor
      t.integer :DataFlags
      t.integer :AccessCode
      t.integer :NameStatus
      t.integer :StatusFlags
      t.integer :OriginalGenusID
      t.string :Distribution
      t.string :Ecology
      t.string :Comment
      t.integer :ExpertID
      t.integer :ExpertReason
      t.integer :CurrentConceptRefID
      t.integer :LifeZone
      t.datetime :LastUpdate
      t.integer :ModifiedBy
      t.datetime :CreatedOn
      t.integer :CreatedBy
      t.integer :UnavailFlags
      t.boolean :HasPreHolocene
      t.boolean :HasModern

      t.index :FileID
      t.index [:FileID, :TaxonNameStr]
      t.index [:FileID, :RankID]
      t.index [:FileID, :Name]
      t.index :AboveID
      t.index :LikeNameID
      t.index :RefID
      t.index :OriginalGenusID
      t.index :ExpertID
      t.index :CurrentConceptRefID
      t.index :ModifiedBy
      t.index :CreatedBy
    end
  end
end
