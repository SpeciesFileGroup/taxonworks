class CreateDownloads < ActiveRecord::Migration[5.2]
  def change
    create_table :downloads do |t|
      t.string :name, null: false
      t.string :description
      t.string :filename, null: false, index: true
      t.string :request, index: true
      t.datetime :expires, null: false
      t.integer :times_downloaded, null: false, default: 0

      t.timestamps null: false

      t.integer :created_by_id, null: false, index: true
      t.integer :updated_by_id, null: false, index: true

      t.references :project, index: true, foreign_key: true
    end

    add_foreign_key :downloads, :users, column: :created_by_id
    add_foreign_key :downloads, :users, column: :updated_by_id
  end
end
