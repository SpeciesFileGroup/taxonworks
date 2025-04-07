class CreateSounds < ActiveRecord::Migration[7.2]
  def change
    create_table :sounds do |t|
      t.text :name
      t.references :project, foreign_key: true, null: false
      t.bigint :created_by_id, null: false, index: true
      t.bigint :updated_by_id, null: false, index: true

      t.timestamps
    end

    add_foreign_key :sounds, :users, column: :created_by_id
    add_foreign_key :sounds, :users, column: :updated_by_id
  end

end

