class CreateTblFiles < ActiveRecord::Migration[6.0]
  def change
    create_table :tblFiles, primary_key: :FileID do |t|
      t.integer :FileTypeID
      t.string :WebsiteName
      t.integer :AboveID
      t.string :Description
      t.string :URL
      t.string :DateStarted
      t.integer :NumSpecies
      t.integer :NumNames
      t.integer :NumCites
      t.integer :NumImages
      t.integer :NumSpecimens
      t.integer :NumKeyEndPoints
      t.string :FileVersion
      t.integer :Flags
      t.datetime :LastUpdate
      t.integer :ModifiedBy
      t.datetime :CreatedOn
      t.integer :CreatedBy
      t.string :ContactPerson
      t.string :ContactEmail
    end
  end
end
