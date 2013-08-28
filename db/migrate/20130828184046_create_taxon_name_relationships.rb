class CreateTaxonNameRelationships < ActiveRecord::Migration
  def change
    create_table :taxon_name_relationships do |t|
      t.integer :subject_taxon_name_id
      t.integer :object_taxon_name_id
      t.string :type

      t.timestamps
    end
  end
end
