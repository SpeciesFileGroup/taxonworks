class AddSourceIdToTaxonNameRelationships < ActiveRecord::Migration
  def change
    add_column :taxon_name_relationships, :source_id, :integer, index: true
  end
end
