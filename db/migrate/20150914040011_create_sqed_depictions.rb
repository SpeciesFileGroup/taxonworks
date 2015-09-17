class CreateSqedDepictions < ActiveRecord::Migration
  def change
    create_table :sqed_depictions do |t|
      t.references :depiction, index: true, foreign_key: true, null: false
      
      t.string :boundary_color, null: false
      t.string :boundary_finder, null: false
      t.boolean :has_border, null: false
      t.string :layout, null: false
      t.hstore :metadata_map, null: false
      t.hstore :specimen_coordinates 
      t.hstore :result_boundaries
      t.hstore :result_text
      t.references :project, index: true, foreign_key: true, null: false
      t.integer :created_by_id, null: false
      t.integer :updated_by_id, null: false
      t.timestamps null: false
    end

   add_foreign_key :sqed_depictions, :users, column: :created_by_id 
   add_foreign_key :sqed_depictions, :users, column: :updated_by_id 

  end
end
