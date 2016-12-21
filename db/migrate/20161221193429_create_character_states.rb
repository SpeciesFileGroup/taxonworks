class CreateCharacterStates < ActiveRecord::Migration
  def change
    create_table :character_states do |t|
      t.string :name, index: true, null: false 
      t.string :label, index: true, null: false 
      t.references :descriptor, index: true, foreign_key: true, null: false
      t.integer :position
      t.references :project, index: true, foreign_key: true
      t.integer :updated_by_id, index: true, null: false
      t.integer :created_by_id, index: true, null: false

      t.timestamps null: false
    end

    
    add_foreign_key :character_states, :users, column: :created_by_id
    add_foreign_key :character_states, :users, column: :updated_by_id


  end
end
