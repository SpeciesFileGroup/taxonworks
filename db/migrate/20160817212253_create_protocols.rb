class CreateProtocols < ActiveRecord::Migration[4.2]
  def change
    create_table :protocols do |t|
      t.string :name, null: false
      t.text :short_name, null: false
      t.text :description, null: false
      t.integer :created_by_id, null: false
      t.integer :updated_by_id, null: false
      t.references :project, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
