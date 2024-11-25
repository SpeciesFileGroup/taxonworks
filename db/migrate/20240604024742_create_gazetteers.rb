class CreateGazetteers < ActiveRecord::Migration[7.1]
  def change
    create_table :gazetteers do |t|

      t.integer :geographic_item_id, null: false, index: true
      t.integer :parent_id, index: true
      t.string :name, null: false, index: true
      t.string :iso_3166_a2, index: true
      t.string :iso_3166_a3, index: true
      t.references :project, index: true, foreign_key: true

      t.timestamps null: false

      t.integer :created_by_id, null: false, index: true
      t.integer :updated_by_id, null: false, index: true
    end
  end
end
