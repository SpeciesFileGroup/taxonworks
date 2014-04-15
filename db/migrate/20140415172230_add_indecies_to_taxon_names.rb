class AddIndeciesToTaxonNames < ActiveRecord::Migration
  def change
    add_index :taxon_names, :parent_id
    add_index :taxon_names, :lft
    add_index :taxon_names, :rgt
    add_index :taxon_names, :name 
    add_index :taxon_names, :project_id
     
  end
end
