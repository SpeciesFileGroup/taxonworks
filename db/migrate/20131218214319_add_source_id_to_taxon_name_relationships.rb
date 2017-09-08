class AddSourceIdToTaxonNameRelationships < ActiveRecord::Migration[4.2]
  def change
    add_column :taxon_name_relationships, :source_id, :integer, index: true
  end
end
