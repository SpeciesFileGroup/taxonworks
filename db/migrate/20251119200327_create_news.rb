class CreateNews < ActiveRecord::Migration[7.2]
  def change
    create_table :news do |t|
      t.text :type
      t.text :title
      t.text :body
      t.datetime :display_start
      t.datetime :display_end
      t.references :project, foreign_key: true
      t.integer :created_by_id
      t.integer :updated_by_id

      t.timestamps
    end
    
    add_foreign_key :news, :users, column: :created_by_id
    add_foreign_key :news, :users, column: :updated_by_id

  end
end
