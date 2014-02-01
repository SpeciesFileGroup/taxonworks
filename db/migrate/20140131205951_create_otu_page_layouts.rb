class CreateOtuPageLayouts < ActiveRecord::Migration
  def change
    create_table :otu_page_layouts do |t|
      t.string :name
      t.integer :created_by_id
      t.integer :updated_by_id 
      t.integer :project_id 
      t.timestamps
    end
  end
end
