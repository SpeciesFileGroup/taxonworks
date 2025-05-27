class DropGazetteerHierarchiesTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :gazetteer_hierarchies
  end
end
