class DropSourceIdFromTables < ActiveRecord::Migration[4.2]

  def change
    remove_column :taxon_names, :source_id
    remove_column :taxon_name_relationships, :source_id
    remove_column :biological_associations_graphs, :source_id 
    remove_column :georeferences, :source_id 
    remove_column :type_materials, :source_id 
  end
  
end
