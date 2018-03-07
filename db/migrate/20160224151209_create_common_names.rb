class CreateCommonNames < ActiveRecord::Migration[4.2]
  def change
    create_table :common_names do |t|
      t.string :name, null: false, index: true
      t.references :geographic_area, index: true, foreign_key: true
      t.references :otu, index: true, foreign_key: true
      t.references :language, index: true, foreign_key: true
      t.integer :start_year
      t.integer :end_year

      t.references :project, index: true, foreign_key: true, null: false
      t.integer :created_by_id, index: true, null: false
      t.integer :updated_by_id, index: true, null: false

      t.timestamps null: false
    end

    add_foreign_key :common_names, :users, column: :created_by_id
    add_foreign_key :common_names, :users, column: :updated_by_id

  end
end
