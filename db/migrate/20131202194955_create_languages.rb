class CreateLanguages < ActiveRecord::Migration
  def change
    create_table :languages do |t|
      t.string :alpha_3_bibliographic
      t.string :alpha_3_terminologic
      t.string :alpha_2
      t.string :english_name
      t.string :french_name

      t.timestamps
    end
  end
end
