class CreateTblNomenclator < ActiveRecord::Migration[6.0]
  def change
    create_table :tblNomenclator, primary_key: :NomenclatorID do |t|
      t.integer :FileID
      t.integer :GenusNameID
      t.integer :SubgenusNameID
      t.integer :InfragenusNameID
      t.integer :SpeciesSeriesNameID
      t.integer :SpeciesGroupNameID
      t.integer :SpeciesSubgroupNameID
      t.integer :SpeciesNameID
      t.integer :SubspeciesNameID
      t.integer :InfrasubKind
      t.integer :InfrasubspeciesNameID
      t.integer :SuitableForRanks
      t.string :IdentQualifier
      t.integer :RankQualified
      t.datetime :LastUpdate
      t.integer :ModifiedBy
      t.datetime :CreatedOn
      t.integer :CreatedBy

      
      t.index :FileID
      t.index :GenusNameID
      t.index :SubgenusNameID
      t.index :InfragenusNameID
      t.index :SpeciesSeriesNameID
      t.index :SpeciesGroupNameID
      t.index :SpeciesSubgroupNameID
      t.index :SpeciesNameID
      t.index :SubspeciesNameID
      t.index :InfrasubspeciesNameID
      t.index :ModifiedBy
      t.index :CreatedBy
    end
  end
end
