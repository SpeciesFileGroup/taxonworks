class AddTaxonNameRelationshipNotNulls < ActiveRecord::Migration
  def change
    TaxonNameRelationship.connection.execute('ALTER TABLE taxon_name_relationships ALTER COLUMN subject_taxon_name_id SET NOT NULL;')
    TaxonNameRelationship.connection.execute('ALTER TABLE taxon_name_relationships ALTER COLUMN object_taxon_name_id SET NOT NULL;')
    TaxonNameRelationship.connection.execute('ALTER TABLE taxon_name_relationships ALTER COLUMN type SET NOT NULL;')
  end
end
