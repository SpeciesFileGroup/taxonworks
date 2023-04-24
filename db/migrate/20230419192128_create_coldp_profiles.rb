class CreateColdpProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :coldp_profiles do |t|
      t.string :title_alias
      t.references :project, foreign_key: true
      t.references :otu, foreign_key: true
      t.boolean :prefer_unlabelled_otu
      t.integer :checklistbank
      t.string :export_interval

      t.timestamps
    end
  end
end
