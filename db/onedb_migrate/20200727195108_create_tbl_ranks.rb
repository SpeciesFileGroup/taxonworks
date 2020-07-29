class CreateTblRanks < ActiveRecord::Migration[6.0]
  def change
    create_table :tblRanks, primary_key: :RankID do |t|
      t.string :RankName
      t.integer :DefaultLevel
    end
  end
end
